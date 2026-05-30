# Settings

## Disable Developer Mode
```
adb shell settings put global --user 0 development_settings_enabled 0
```

## Enable Developer Mode
```
adb shell settings put global --user 0 development_settings_enabled 1
```

## Delete Developer Settings
```
adb shell settings delete global --user 0 development_settings_enabled
```

## Enable ADB over USB
```
adb shell settings put global --user 0 adb_enabled 1
```

## Enable ADB over Wi-Fi
```
adb shell settings put global --user 0 adb_wifi_enabled 1
```

## Set the Allowed Connection Timeout for ADB
```
adb shell settings put global --user 0 adb_allowed_connection_time 1
```

## Enable or Disable Airplane Mode
```
adb shell settings put global --user 0 airplane_mode_on 0
```

## Set the Radios for Airplane Mode
```
adb shell settings put global --user 0 airplane_mode_radios cell,bluetooth,wifi,nfc,wimax
```

## Set the Toggleable Radios for Airplane Mode
```
adb shell settings put global --user 0 airplane_mode_toggleable_radios cell,bluetooth,wifi,nfc
```

## Enable Secure Wi-Fi Backup Existence
```
adb shell settings put global --user 0 SecureWifiBackupExist 1
```

## Set the Notification Sound Timeout for Low Battery
```
adb shell settings put global --user 0 low_battery_sound_timeout 0
```

## Set the Default Video Quality
```
adb shell settings put global --user 0 video_quality 1080
```

## Set the User Setup Complete Status for Optimizing Apps at Boot
```
adb shell settings put secure --user 0 user_setup_complete 1
```

## Allow Private Notifications on the Lock Screen
```
adb shell settings put secure --user 0 lock_screen_allow_private_notifications 1
```

## Set the Lock Screen Timeout in Milliseconds
```
adb shell settings put secure --user 0 lock_screen_lock_after_timeout 5000
```

## Enable or Disable Owner Info on the Lock Screen
```
adb shell settings put secure --user 0 lock_screen_owner_info_enabled 0
```

## Show Notifications on the Lock Screen
```
adb shell settings put secure --user 0 lock_screen_show_notifications 1
```

## Enable or Disable the Lock Screen
```
adb shell settings put secure --user 0 lockscreen.disabled 0
```

## Enable Face Unlock for the Lock Screen
```
adb shell settings put secure --user 0 lockscreen.options enable_facelock
```

## Show Controls on the Lock Screen
```
adb shell settings put secure --user 0 lockscreen_show_control 0
```

## Show the Wallet on the Lock Screen
```
adb shell settings put secure --user 0 lockscreen_show_wallet 1
```

## Show the Face Widget Area on the Lock Screen
```
adb shell settings put secure --user 0 lockstar_facewidget_area 1
```

## Enable Mock Location (Required for Fake GPS)
```
adb shell settings put secure --user 0 mock_location 1
```
