# Android ADB Shell Clipboard Commands

## Paste clipboard
```
adb shell input keyevent PASTE
```

## Paste clipboard (Alternative)
```
adb shell input keyevent 279
```

## Paste clipboard (Old devices only)
```
adb shell service call clipboard 1
```

## Set application with read permissions for clipboard
```
adb shell cmd appops set com.bankid.bus READ_CLIPBOARD allow
```

## Add text to clipboard
```
adb shell am broadcast -a clipper.set -e text "text"
```
