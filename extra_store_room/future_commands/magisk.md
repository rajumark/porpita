# Magisk Commands Reference

## Print Current Binary Version
```
magisk -c
```

## Print Running Daemon Version
```
magisk -v
```

## Print Running Daemon Version Code
```
magisk -V
```

## List All Available Applets
```
magisk --list
```

## Remove All Modules
```
magisk --remove-modules
```

## Remove All Modules Without Reboot
```
magisk --remove-modules -n
```

## Install a Module from a ZIP File
```
magisk --install-module ZIP
```

## Manually Start Magisk Daemon
```
magisk --daemon
```

## Remove All Magisk Changes and Stop Daemon
```
magisk --stop
```

## Callback on Init Triggers
```
magisk --[init trigger]
```

## Set BLKROSET Flag to OFF for All Block Devices
```
magisk --unlock-blocks
```

## Restore SELinux Context on Magisk Files
```
magisk --restorecon
```

## Clone Permission, Owner, and SELinux Context
```
magisk --clone-attr SRC DEST
```

## Clone SRC to DEST
```
magisk --clone SRC DEST
```

## Execute SQL Commands to Magisk Database
```
magisk --sqlite SQL
```

## Print Magisk TMPFS Mount Path
```
magisk --path
```

## Denylist Config CLI
```
magisk --denylist ARGS
```

## Resolve a Device to Store Preinit Files
```
magisk --preinit-device
```

## Available Applets
```
su, resetprop
```
