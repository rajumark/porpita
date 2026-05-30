# Mastering Android Service

## Enable oem lock even when its grayed out
```
su -c service call oem_lock 2 i32 1
```

## Disable oem lock even when its grayed out
```
su -c service call oem_lock 2 i32 0
```

## Set Keyguard Security Enabled
- logcat tag: KG.Utils
```
service call knoxguard_service 37
```

## Set Keyguard Security Lock Disabled
- logcat tag: KG.Utils
```
logcat -s HIDL_KGTA_CLIENT -s KGTA_impls -s TZ -s HIDL_KGTA_CLIENT -s KGTA_HIDL_SERVICE -s KGTA_Initialize -s HidlServiceManagement -s KnoxGuardTANative -s KG.KnoxGuardSeService -s HidlServiceManagement -s KNOX_MDM_SettingsProvider -s InputMethodManagerService -s KeyguardSecSecurityContainer -s KG.KnoxGuardSeService -s setKGSystemProperty -s KeyguardKnoxGuardView -s SystemUITextView -s KeyguardSecurityView -s ENTM:EventsManager -s
```

```
service call knoxguard_service 36
```

## Call OTA upgrade
```
service call knoxguard_service 5
```

## Print Phone Number
```
adb shell 'service call iphonesubinfo 19' \
| awk -F "'" '{print $2}' \
| tr -d '\n' \
| sed 's/\s\+/\n/g' \
| tr -d '.' \
| awk '{if ($0) print $0; else print "No phone number found"}'
```

## Print Provider
```
adb shell 'service call iphonesubinfo 26' \
| awk -F "'" '{print $2}' \
| tr -d '.' \
| xargs \
| sed 's/ //g'
```

## Get Device IMEI Number
```
adb shell 'service call iphonesubinfo 1' \
| awk -F "\'" '{print $2}' \
| sed '1 d' \
| awk '{print}' ORS=''
```

## Get Android Device's Phone Number
```
adb shell 'service call iphonesubinfo 19' \
| awk -F "\'" '{print $2}' \
| sed '1 d' \
| awk '{print}' ORS=''
```

## Get Android Device's Carrier Information
```
adb shell 'service call iphonesubinfo 10' \
| awk -F "\'" '{print $2}' \
| sed '1 d' \
| awk '{print}' ORS=''
```

## Get Android Device ID
```
adb shell 'service call iphonesubinfo 3' \
| awk -F "\'" '{print $2}' \
| sed '1 d' \
| awk '{print}' ORS=''
```

## Enable OEM_LOCK no matter if it's inactive or not in developer menu
```
service call oem_lock 2 i32 1
```

## Disable OEM_LOCK no matter if it's inactive or not in developer menu
- Please notice if you will reboot and keep the bootloader unlocked it will re-enable this feature during the setup. During the reboot please wait until UI Optimizing Apps will run and then just wait until it boots!
```
service call oem_lock 2 i32 0
```

## MDM Lock down - KG Protection
```
service call knoxguard_service 37
```

## MDM Unlock - Remove KG Protection
```
service call knoxguard_service 41 s16 'null' service call knoxguard_service 40
```

## Follow the knoxguard_service lock/unlock with logcat
```
adb shell 'su -c logcat -s system_server'
```
