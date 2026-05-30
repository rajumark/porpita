# Safety Center

## Prints the name of the package that contains Safety Center
```
adb shell cmd safety_center package-name
```

## Clear all data held by Safety Center
- Includes data held in memory and persistent storage but not the listeners.
- USERID is a user ID; refresh sources in this user profile group (default 0)
- REASON is one of PAGE_OPEN, BUTTON_CLICK, REBOOT, LOCALE CHANGE, SAFETY_CENTER_ENABLED, OTHER, PERIODIC; determines whether sources fetch fresh data (default OTHER)

```
adb shell cmd safety_center clear-data
```

## Start a refresh of all sources
```
adb shell cmd safety_center refresh --reason REBOOT --user 0
```

## Check if this device supports Safety Center
Prints "true" if supported, "false" otherwise
```
adb shell cmd safety_center supported
```

## Check if Safety Center is enabled
Prints "true" if enabled, "false" otherwise
```
adb shell cmd safety_center enabled
```
