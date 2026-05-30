# Statusbar

## Expand the Notifications Panel
```
adb shell cmd statusbar expand-notifications
```

## Expand the Notifications Panel and Expand Quick Settings if Present
```
adb shell cmd statusbar expand-settings
```

## Collapse the Notifications and Settings Panel
```
adb shell cmd statusbar collapse
```

## Add a TileService of the Specified Component
```
adb shell cmd statusbar add-tile COMPONENT
```

## Remove a TileService of the Specified Component
```
adb shell cmd statusbar remove-tile COMPONENT
```

## Click on a TileService of the Specified Component
```
adb shell cmd statusbar click-tile COMPONENT
```

## Check if this Device Supports Quick Settings + APIs
```
adb shell cmd statusbar check-support
```

## Print the List of Status Bar Icons and their Order
```
adb shell cmd statusbar get-status-icons
```

## Disable Status Bar Components Unsuitable for Device Setup
```
adb shell cmd statusbar disable-for-setup DISABLE
```

## Re-enable All Status Bar Components
```
adb shell cmd statusbar send-disable-flag none
```

## Disable Search in the Status Bar
```
adb shell cmd statusbar send-disable-flag search
```

## Disable Navigation Home in the Status Bar
```
adb shell cmd statusbar send-disable-flag home
```

## Disable Recent Apps/Overview in the Status Bar
```
adb shell cmd statusbar send-disable-flag recents
```

## Disable Notification Peeking in the Status Bar
```
adb shell cmd statusbar send-disable-flag notification-peek
```

## Disable Status Bar Expansion
```
adb shell cmd statusbar send-disable-flag statusbar-expansion
```

## Disable System Icons Appearing in the Status Bar
```
adb shell cmd statusbar send-disable-flag system-icons
```

## Disable the Clock Appearing in the Status Bar
```
adb shell cmd statusbar send-disable-flag clock
```

## Disable Notification Icons from Appearing in the Status Bar
```
adb shell cmd statusbar send-disable-flag notification-icons
```

## List All Preferences of the Status Bar
```
adb shell cmd statusbar prefs list-prefs
```

## Hide All Fingerprint-related Icons in the Status Bar
```
adb shell cmd statusbar udfps
```

## Show Fingerprint-related Icons in the Status Bar
```
adb shell cmd statusbar udfps show enroll-find-sensor
```

## Show Fingerprint-related Icons in the Status Bar
```
adb shell cmd statusbar udfps show enroll-enrolling
```

## Show Fingerprint-related Icons in the Status Bar
```
adb shell cmd statusbar udfps show auth-bp
```

## Show Fingerprint-related Icons in the Status Bar
```
adb shell cmd statusbar udfps show auth-keyguard
```

## Show Fingerprint-related Icons in the Status Bar
```
adb shell cmd statusbar udfps show auth-other
```

## Show Fingerprint-related Icons in the Status Bar
```
adb shell cmd statusbar udfps show auth-settings
```
