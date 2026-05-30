# Android Netpolicy Commands

## Add Restrict Background Whitelist
```
adb shell cmd netpolicy add restrict-background-whitelist UID
```

## Add Restrict Background Blacklist
```
adb shell cmd netpolicy add restrict-background-blacklist UID
```

## Add App Idle Whitelist
```
adb shell cmd netpolicy add app-idle-whitelist UID
```

## Get Restrict Background
```
adb shell cmd netpolicy get restrict-background
```

## List WiFi Networks
```
adb shell cmd netpolicy list wifi-networks [true|false]
```

## List Restrict Background Whitelist
```
adb shell cmd netpolicy list restrict-background-whitelist
```

## List Restrict Background Blacklist
```
adb shell cmd netpolicy list restrict-background-blacklist
```

## Remove Restrict Background Whitelist
```
adb shell cmd netpolicy remove restrict-background-whitelist UID
```

## Remove Restrict Background Blacklist
```
adb shell cmd netpolicy remove restrict-background-blacklist UID
```

## Remove App Idle Whitelist
```
adb shell cmd netpolicy remove app-idle-whitelist UID
```

## Set Metered Network
```
adb shell cmd netpolicy set metered-network ID [undefined|true|false]
```

## Set Restrict Background
```
adb shell cmd netpolicy set restrict-background BOOLEAN
```

## Set Sub Plan Owner
```
adb shell cmd netpolicy set sub-plan-owner subId [packageName]
```
