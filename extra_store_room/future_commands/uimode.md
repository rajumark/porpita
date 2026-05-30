# UI Mode Management

## Retrieve the Current UI Mode
```
adb shell cmd uimode
```

## Set UI Mode to Night Mode (Dark Theme) Permanently
```
adb shell cmd uimode night yes
```

## Set UI Mode to Day Mode (Light Theme) Permanently
```
adb shell cmd uimode night no
```

## Set UI Mode to Automatic
Allows the device to switch between day and night modes based on the system settings.
```
adb shell cmd uimode night auto
```

## Set UI Mode to Custom Schedule
```
adb shell cmd uimode night custom_schedule
```

## Set UI Mode to Custom Schedule with Bedtime
```
adb shell cmd uimode night custom_bedtime
```

## Set UI Mode to Car Mode
```
adb shell cmd uimode car yes
```

## Disable Car Mode
```
adb shell cmd uimode night no
```

## Set Start Time for Custom UI Mode Schedule
```
adb shell cmd uimode time start 18:00
```

## Set End Time for Custom UI Mode Schedule
```
adb shell cmd uimode time end 07:00
```
