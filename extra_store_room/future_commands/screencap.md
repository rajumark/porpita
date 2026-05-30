# Screencap

## Take a Screenshot and Save it to a Specific Location
```
adb shell screencap /storage/emulated/0/Pictures/screenshot.png
```

## Take a Screenshot and Save it with a Timestamp in the Filename
```
adb shell screencap /storage/emulated/0/Pictures/screenshot_$(date +%Y%m%d_%H%M%S).png
```

## Take a Screenshot and Display it on the Screen
```
adb shell screencap -p | display
```

## Take a Screenshot and Transfer it to Your Computer
```
adb shell screencap -p > screenshot.png
```

## Take a Screenshot of a Specific Device Using its Serial Number
```
adb -s DEVICE_SERIAL shell screencap /storage/emulated/0/Pictures/screenshot.png
```
