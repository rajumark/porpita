# Android ADB Service Control Cheatsheet

## Power Manager Control
```
adb shell svc power
```

## Set 'Keep Awake While Plugged In' Setting
```
adb shell svc power stayon [true|false|usb|ac|wireless]
```

## Reboot the Device with the Specified Reason
```
adb shell svc power reboot [reason]
```

## Power Off the Device
```
adb shell svc power shutdown
```

## Force the System into Suspend, Ignoring All Wakelocks
```
adb shell svc power forcesuspend -t <milliseconds>
```

## Set the Current USB Function
If the function is blank, it sets to charging.
```
adb shell svc usb setScreenUnlockedFunctions [function]
```

## Get the List of Currently Enabled USB Functions
```
adb shell svc usb getFunctions
```

## Reset the USB Gadget
```
adb shell svc usb resetUsbGadget
```

## Get the Current USB Speed
```
adb shell svc usb getUsbSpeed
```

## Get the Current Gadget HAL Version
```
adb shell svc usb getGadgetHalVersion
```

## Get the Current USB HAL Version
```
adb shell svc usb getUsbHalVersion
```

## Reset the Specified Connected USB Port
```
adb shell svc usb resetUsbPort [port number]
```

## NFC Control
```
adb shell svc nfc
```

## System Server Process
```
adb shell svc system-server
```

## Enable NFC
```
adb shell svc nfc enable
```

## Disable NFC
```
adb shell svc nfc disable
```

## Enable Wi-Fi
```
adb shell svc wifi enable
```

## Disable Wi-Fi
```
adb shell svc wifi disable
```
