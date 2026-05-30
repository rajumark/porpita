# Android ADB Shell Netpolicy

## Clear Time
```
adb shell cmd network_time_update_service clear_time
```

## Force Refresh
```
adb shell cmd network_time_update_service force_refresh
```

## Set Server Config
```
adb shell cmd network_time_update_service set_server_config --hostname <hostname> --port <port> --timeout_millis <millis>
```
