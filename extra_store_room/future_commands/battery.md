# Ultimate Guide to Battery Management with ADB Commands

## Dump data for all of the running services, dump all data for battery
```
adb shell dumpsys battery
```

## Dump stats for your battery
```
adb shell dumpsys batterystats
```

## Erase old stats for battery
```
adb shell dumpsys batterystats --reset
```

## Unplug AC
```
adb shell dumpsys battery unplug
```

## Freezing Battery State
```
adb shell cmd battery unplug -f
```

## Unfreeze Battery State
```
adb shell cmd battery reset -f
```

## Dump Battery Level
```
adb shell cmd battery get level | sed 's/.*/Battery:&%/'
```

## Dump all settings for cmd battery (posix)
```
#!/bin/bash
batstats="ac usb wireless status level temp present counter invalid"
for batstat in $batstats; do
    value=$(adb shell cmd battery get "$batstat")
    printf "%-8s: %s\n" "$batstat" "$value"
done
```
