# Window Manager

## Prints the help text
```
adb shell wm help
```

## Reset the display size to default
```
adb shell wm size reset
```

## Set the display size to a specific width and height in pixels
```
adb shell wm size 1080x1920
```

## Set the display size to a specific width and height in density-independent pixels
```
adb shell wm size 720x1280dp
```

## Set the display size for a specific display ID
```
adb shell wm size 1080x1920 -d 0
```

## Display Scaling Control

### Turn off display scaling
```
adb shell wm density reset
```

### Set display scaling to automatic mode
```
adb shell wm density auto
```

### Set display scaling for a specific display ID
```
adb shell wm density 420 -d 0
```

## Keyguard Dismissal

### Dismisses the keyguard
```
adb shell wm dismiss-keyguard
```

## User Rotation Settings

### Print the user rotation mode and user rotation
```
adb shell wm rotation
```

### Set the user rotation mode to free
```
adb shell wm rotation free
```

### Set the user rotation mode to lock and specify the rotation value
```
adb shell wm rotation lock 0
```

### Set the user rotation mode for a specific display ID
```
adb shell wm rotation lock 0 -d 0
```

## View Hierarchy Information

### Dumps the encoded view hierarchies of visible windows
```
adb shell wm dump-visible-window-hierarchies
```

## App Requested Orientation

### Print the rotating display for app requested orientation
```
adb shell wm get-rotate-display-for-app-requested-orientation
```

### Set the rotating display for app requested orientation to enabled
```
adb shell wm set-rotate-display-for-app-requested-orientation enabled
```

### Set the rotating display for app requested orientation to disabled for a specific display ID
```
adb shell wm set-rotate-display-for-app-requested-orientation disabled -d 0
```

## Ignore App Requested Orientation

### Set whether to ignore app requested orientation to true
```
adb shell wm set-ignore-orientation-request true
```

### Set whether to ignore app requested orientation to false for a specific display ID
```
adb shell wm set-ignore-orientation-request false -d 0
```

### Prints whether app requested orientation should be ignored
```
adb shell wm get-ignore-orientation-request
```

## Multi-Window Configuration

### Set multi-window config options (Needs specific parameters)
```
adb shell wm set-multi-window-config
```

### Prints values of the multi-window config options
```
adb shell wm get-multi-window-config
```

### Resets overrides to default values of the multi-window config options
```
adb shell wm reset-multi-window-config
```

## Other Settings

### Resets all override settings
```
adb shell wm reset
```

### Return or override display size and density at once
```
adb shell wm size 1080x1920 && adb shell wm density 420
```

### Reset the folded area to default
```
adb shell wm reset-folded-area
```

### Set the folded area to specific left, top, right, and bottom values
```
adb shell wm set-folded-area 0 0 1080 1920
```
