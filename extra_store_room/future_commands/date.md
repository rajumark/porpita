# Android ADB Shell Date and Time Commands

## Set time
```
adb shell "date HH:mm;am broadcast -a android.intent.action.TIME_SET"
```

## Set date and time
```
adb shell date MMDDhhmmYYYY.ss;am broadcast -a android.intent.action.TIME_SET
```

## Set time zone
```
adb shell setprop persist.sys.timezone "America/Los_Angeles"
```

## Print current date and time
```
adb shell date
```

## Print current time in milliseconds since January 1, 1970 UTC
```
adb shell date +%s%3N
```

## Print current time in seconds since January 1, 1970 UTC
```
adb shell date +%s
```
