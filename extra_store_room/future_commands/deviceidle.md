# Device Idle Controller

## Print help for deviceidle
```
adb shell cmd deviceidle help
```

## Immediately step to next state, without waiting for alarm
```
adb shell cmd deviceidle step [light|deep]
```

## Force directly into idle mode, regardless of other device state
```
adb shell cmd deviceidle force-idle [light|deep]
```

## Force to be inactive, ready to freely step idle states
```
adb shell cmd deviceidle force-inactive
```

## Resume normal functioning after force-idle or force-inactive
```
adb shell cmd deviceidle unforce
```

## Retrieve the current given state
```
adb shell cmd deviceidle get [light|deep|force|screen|charging|network]
```

## Completely disable device idle mode
```
adb shell cmd deviceidle disable [light|deep|all]
```

## Re-enable device idle mode after it had previously been disabled
```
adb shell cmd deviceidle enable [light|deep|all]
```

## Print 1 if device idle mode is currently enabled, else 0
```
adb shell cmd deviceidle enabled [light|deep|all]
```

## Print currently whitelisted apps
```
adb shell cmd deviceidle whitelist
```

## Add (prefix with +) or remove (prefix with -) packages
```
adb shell cmd deviceidle whitelist [package ...]
```

## Manage system whitelist packages and reset to original state
```
adb shell cmd deviceidle sys-whitelist [package ...|reset]
```

## Manage exception idle whitelist, non-persistent across boots
```
adb shell cmd deviceidle except-idle-whitelist [package ...|reset]
```

## Print packages that are temporarily whitelisted
```
adb shell cmd deviceidle tempwhitelist
```

## Temporarily whitelist a package for a specified duration
```
adb shell cmd deviceidle tempwhitelist [-u USER] [-d DURATION] [-r] [package]
```

## Simulate a motion event to bring the device out of deep doze
```
adb shell cmd deviceidle motion
```

## Set a new factor to idle time before stepping to idle
```
adb shell cmd deviceidle pre-idle-factor [0|1|2]
```

## Reset factor to idle time to default
```
adb shell cmd deviceidle reset-pre-idle-factor
```
