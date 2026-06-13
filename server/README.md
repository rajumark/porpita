# Porpita Server — Android On-Device DEX

This directory contains the Android server project that runs on the connected device to fetch app icons. It is compiled into a DEX file (`porpita.dex`), pushed to the device via ADB, and executed as a standalone runtime via `app_process`.

## Architecture Overview

```
┌──────────────────────────────────────────────────────┐
│               Porpita Desktop App (Flutter)          │
│                                                      │
│  AppIconService                                      │
│      ├── PorpitaServer (socket client)                │
│      │     ├── push DEX to device                    │
│      │     ├── start server via app_process          │
│      │     ├── send/receive JSON over socket         │
│      │     └── HTTP file server port forwarding       │
│      │                                                │
│      └── Downloads PNG icons via HTTP                │
│                                                      │
└──────────────────────────┬───────────────────────────┘
                           │ ADB
                           ▼
┌──────────────────────────────────────────────────────┐
│              Android Device                           │
│                                                      │
│  porpita.dex (runs via app_process)                  │
│      ├── Server.kt    → LocalServerSocket "porpita"  │
│      ├── Connection.kt → handles JSON requests      │
│      ├── ServiceManager.kt → hidden API access       │
│      ├── PackageManager.kt → package info queries    │
│      ├── HttpFileServer.kt → serves icon PNGs       │
│      └── Util.kt       → Drawable → PNG conversion   │
│                                                      │
│  Icons cached at: /data/local/tmp/porpita/icons/     │
└──────────────────────────────────────────────────────┘
```

## How to Build the DEX

### Prerequisites

- JDK 17+ (tested with Corretto 20)
- Android SDK with platform 35 and build-tools 34+

### Build Commands

```bash
# Set environment
export JAVA_HOME=/path/to/jdk
export ANDROID_HOME=$HOME/Library/Android/sdk

# Build the DEX
cd server
./gradlew :server:extractDex

# The DEX file will be at: server/porpita.dex
```

### Where to Place the DEX

Copy the built DEX into the Flutter project's assets:

```bash
cp server/porpita.dex ../assets/dex/porpita.dex
```

The DEX is bundled as a Flutter asset and extracted at runtime to the app support directory.

## Protocol (JSON over Length-Delimited Socket)

### Connection Setup

1. Flutter checks if server is running: `adb shell cat /proc/net/unix` → look for `@porpita`
2. If not running, push DEX: `adb push <local-dex> /data/local/tmp/porpita/porpita.dex`
3. Start server: `adb shell CLASSPATH=/data/local/tmp/porpita/porpita.dex app_process /system/bin io.porpita.server.Server`
4. Wait for `@porpita` to appear in `/proc/net/unix`
5. Forward port: `adb forward tcp:<local-port> localabstract:porpita`
6. Connect TCP socket to `127.0.0.1:<local-port>`

### Message Format

Each message is a length-delimited JSON frame:

```
[4 bytes: big-endian length N] [N bytes: UTF-8 JSON]
```

### Request

```json
{
  "id": "unique-request-id",
  "method": "getAppIcons",
  "params": {
    "packageNames": ["com.example.app1", "com.example.app2"]
  }
}
```

### Response

```json
{
  "id": "same-request-id",
  "result": {
    "com.example.app1": "/data/local/tmp/porpita/icons/com.example.app1.12345.png",
    "com.example.app2": ""
  }
}
```

Empty string means the app has no icon resource.

### Supported Methods

| Method                | Params                          | Response                                          |
| --------------------- | ------------------------------- | ------------------------------------------------- |
| `getAppIcons`         | `{ packageNames: string[] }`    | `{ packageName: iconPath_or_empty_string, ... }` |
| `startFileServer`     | (none)                          | `{ port: number }`                                |
| `isFileServerRunning` | (none)                          | `{ running: boolean }`                            |

## Icon Fetching Flow

```
1. Flutter calls AppIconService.fetchIcons(["com.whatsapp", ...])

2. PorpitaServer sends JSON request over socket:
   {"id":"abc","method":"getAppIcons","params":{"packageNames":["com.whatsapp",...]}}

3. Connection.kt on device:
   - For each package: queries PackageManager via hidden API
   - Loads app's Resources via AssetManager.addAssetPath(apkPath)
   - Extracts icon Drawable → converts to PNG → saves to cache dir
   - Returns map of packageName → icon file path on device

4. Flutter starts file server:
   {"id":"def","method":"startFileServer"}
   → Response: {"port": 9001}

5. Flutter forwards port:
   adb forward tcp:<local-port> tcp:9001

6. Flutter downloads each icon via HTTP:
   GET http://127.0.0.1:<local-port>/data/local/tmp/porpita/icons/com.whatsapp.139205202.png

7. Icons are saved locally and displayed in the app list UI
```

## Icon Caching

- **On-device cache**: `/data/local/tmp/porpita/icons/<packageName>.<apkSize>.png`
- The `<apkSize>` component ensures cache invalidation when an app is updated
- **On-desktop cache**: `<ApplicationSupport>/app_icons/<packageName>.png`

## Project Structure

```
server/
├── build.gradle              # Root Gradle config
├── settings.gradle           # Includes :server module
├── gradlew / gradlew.bat     # Gradle wrapper
├── gradle/wrapper/           # Gradle wrapper JAR + properties
└── server/
    ├── build.gradle           # Module build + DEX extraction task
    ├── proguard-rules.pro     # Keep all io.porpita.server classes
    └── src/main/
        ├── AndroidManifest.xml  # Minimal (empty manifest)
        └── java/io/porpita/server/
            ├── Server.kt           # Entry point, LocalServerSocket
            ├── Connection.kt       # Request handler, icon extraction
            ├── ServiceManager.kt   # Hidden API access via reflection
            ├── PackageManager.kt   # IPackageManager wrapper
            ├── HttpFileServer.kt   # NanoHTTPD file server
            └── Util.kt             # Drawable/Bitmap/JSON utilities
```

## Key Design Decisions

- **No APK installation**: The DEX runs directly via `app_process` with shell permissions, avoiding the need to install an APK
- **JSON protocol** (simpler than protobuf): Length-delimited JSON over local abstract socket — easy to debug and implement in Dart
- **Hidden API access**: `ServiceManager` uses Java reflection to call `android.os.ServiceManager.getService()` to access `IPackageManager` — this works because `app_process` runs with shell-level permissions
- **HTTP for binary data**: Icons are PNG files served via an embedded HTTP server (NanoHTTPD) on the device, then accessed through ADB port forwarding — avoids sending binary data over the socket
- **Socket name "porpita"**: The local abstract socket is named `porpita` (not "aya") to avoid any naming conflicts