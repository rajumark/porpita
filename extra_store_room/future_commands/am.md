# Mastering Android Activity Manager

## General

### Launch Wifi Status
```
adb shell am start -n 'com.android.settings/.wifi.WifiStatusTest'
```

### Launch USB Settings
```
adb shell su -c am start -a 'android.intent.action.MAIN' -n 'com.sec.usbsettings/.USBSettings'
```
