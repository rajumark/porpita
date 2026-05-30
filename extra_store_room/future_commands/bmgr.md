# Android Backup with ADB and Battery Manager

## User Option
```
adb shell bmgr --user
```

## Enable/Disable Backup Mechanism
```
adb shell bmgr enable
```

## Check Backup Mechanism State
```
adb shell bmgr enabled
```

## List Backup Transports
```
adb shell bmgr list transports
```

## List Restore Sets
```
adb shell bmgr list sets
```

## Set Active Transport
```
adb shell bmgr transport
```

## Initiate Immediate Backup
```
adb shell bmgr run
```

## Erase Backed-Up Data
```
adb shell bmgr wipe
```

## Perform Full-Data Stream Backup
```
adb shell bmgr fullbackup
```

## Run Immediate Backup
```
adb shell bmgr backupnow
```
