# ADB (Android Debug Bridge) Commands

## General Commands

### Create bugreport.zip in /sdcard path
```
adb bugreport /sdcard
```

### List pids of processes hosting a JDWP transport
```
adb jdwp
```

### Show device log
```
adb logcat
```

### Sideload the given full OTA package
```
adb sideload OTAPACKAGE
```

### Restart adbd with root permissions
```
adb root
```

### Restart adbd without root permissions
```
adb unroot
```

### Restart adbd listening on USB
```
adb usb
```

### Restart adbd listening on TCP on PORT
```
adb tcpip <port>
```

### Restart userspace
```
adb reboot userspace
```

### Start adb server
```
adb start-server
```

### Kill adb server
```
adb kill-server
```

### Stop adb server
```
adb stop-server
```

### Kick connection from host side to force reconnect
```
adb reconnect
```

### Kick connection from device side to force reconnect
```
adb reconnect device
```

### Reset offline/unauthorized devices to force reconnect
```
adb reconnect offline
```

### Attach a detached USB device
```
adb attach
```

### Detach from a USB device to allow use by other
```
adb detach
```

### Enter device shell
```
adb shell
```

### Choose escape character, or "none"; default '~'
```
adb shell -e
```

### Don't read from stdin
```
adb shell -n
```

### Disable pty allocation
```
adb shell -T
```

### Allocate a pty if on a tty
```
adb shell -t
```

### Force allocate a pty if on a tty
```
adb shell -tt
```

### Disable remote exit codes and stdout/stderr separation
```
adb shell -x
```

### Run emulator console command
```
adb shell emu COMMAND
```

### Enter device shell when there is more than one device connected
- USB connected:
```
adb -s <serial> shell
```

- Network connected:
```
adb -s <ip:port> shell
```

### Print connection status
```
adb devices -l
```

### Print current adb version installed
```
adb version
```

## Network Commands

### Connect to a device via TCP/IP
```
adb connect <ip:port>
```

### Disconnect all connected devices
```
adb disconnect
```

### Disconnect from the given TCP/IP device
```
adb disconnect <ip:port>
```

### Pair with a device for secure TCP/IP communication
```
adb pair <ip:port> <pairing_code>
```

### List all forward socket connections
```
adb forward --list
```

### Forward socket connection
```
adb forward <local> <remote>
```

### Remove a specific forward socket connection
```
adb forward --remove <local>
```

### Remove all forward socket connections
```
adb forward --remove-all
```

### Run PPP over USB
```
adb ppp <tty> [params]
```

### List all reverse socket connections
```
adb reverse --list
```

### Reverse socket connection using
```
adb reverse <remote> <local>
```

### Remove a specific reverse socket connection
```
adb reverse --remove <remote>
```

### Remove all reverse socket connections
```
adb reverse --remove-all
```

### Check if mdns discovery is available
```
adb mdns check
```

### List all discovered services
```
adb mdns services
```

## Miscellaneous Commands

### Disable dm-verity checking on userdebug builds
```
adb disable-verity
```

### Re-enable dm-verity checking on userdebug builds
```
adb enable-verity
```

### Generate adb public/private key
```
adb keygen <file>
```

### Print device state
```
adb get-state
```

### Print device serial number
```
adb get-serialno
```

### Print the device path
```
adb get-devpath
```

### Remount partitions read-write
```
adb remount
```
