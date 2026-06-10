# Porpita

A cross-platform desktop GUI for Android Debug Bridge (ADB) built with Flutter. Provides a full-featured graphical interface to manage Android devices, making common ADB operations accessible without the command line.

## Platform Supported

- macOS
- Windows
- Linux

## Features

- Device management (connect, disconnect, track multiple devices)
- Built-in terminal with ADB shell access
- Screen capture and recording
- App management (install, uninstall, list packages)
- File browser with push/pull support
- Logcat viewer
- Emulator management
- Contact, SMS, and call log viewers
- System properties and settings editor
- Light/dark theme support

## Installation

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (3.x or later)

### Build from source

```sh
git clone https://github.com/your-org/porpita.git
cd porpita
flutter pub get
flutter run -d macos    # or -d windows, -d linux
```

### Pre-built binaries

Download the latest release for your platform from the [Releases](https://github.com/your-org/porpita/releases) page.

## License

MIT
