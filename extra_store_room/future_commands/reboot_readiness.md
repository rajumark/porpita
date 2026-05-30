# Seamless Android Reboots with Reboot Readiness

## Checks interactivity state
```
adb shell cmd reboot_readiness check-interactivity-state
```

## Checks background app activity state. If --list-blocking is passed
```
adb shell cmd reboot_readiness check-app-activity-state --list-blocking
```

## Checks subsystems state. If --list-blocking is passed
```
adb shell cmd reboot_readiness check-subsystems-state --list-blocking
```

## Performs reboot readiness checks for either 5 minutes, or the number of seconds declared by TIMEOUT-SECS
```
adb shell cmd reboot_readiness start-readiness-checks --timeout-secs <TIMEOUT-SECS>
```

## Additional flags that may be passed

### How frequently the reboot readiness state is polled, in milliseconds
```
--poll-interval-ms
```

### How long the device must not have been interacted with before being deemed ready to reboot
```
--minimum-interactivity-duration-ms
```

### Disable interactivity checks
```
--skip-interactivity-check
```

### Disable subsystems checks
```
--skip-subsystems-check
```

### Disable app activity checks
```
--skip-app-activity-check
```
