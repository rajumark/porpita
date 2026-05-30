# Mastering Wi-Fi Management on Android: The Ultimate Guide

## Gets the country code as a two-letter string
```
adb shell cmd wifi get-country-code
```

## Enables or disables Wi-Fi on this device
```
adb shell cmd wifi set-wifi-enabled enabled|disabled
```

## Sets whether scanning should be available even when Wi-Fi is off
```
adb shell cmd wifi set-scan-always-available enabled|disabled
```

## Lists the latest scan results
```
adb shell cmd wifi list-scan-results
```

## Starts a new scan
```
adb shell cmd wifi start-scan
```

## Lists the saved networks
```
adb shell cmd wifi list-networks
```

## Removes the network mentioned by <networkId>
```
adb shell cmd wifi forget-network <networkId>
```

## Displays the current Wi-Fi status
```
adb shell cmd wifi status
```

## Sets verbose logging to be enabled or disabled
```
adb shell cmd wifi set-verbose-logging enabled|disabled
```

## Checks whether verbose logging is enabled or disabled
```
adb shell cmd wifi is-verbose-logging
```

## Temporarily disables all Wi-Fi networks except merged carrier networks with the given subId
```
adb shell cmd wifi start-restricting-auto-join-to-subscription-id subId
```

## Undoes the effects of the start-restricting-auto-join-to-subscription-id command
```
adb shell cmd wifi stop-restricting-auto-join-to-subscription-id
```

## Remove a Network Suggestion with Provided SSID
```
adb shell cmd wifi remove-suggestion <ssid> -l
```

## Remove All Suggestions Added via Shell
```
adb shell cmd wifi remove-all-suggestions
```

## List Suggested Networks Added via Shell
```
adb shell cmd wifi list-suggestions
```

## Set a single LTE cell channel
```
adb shell cmd wifi set-coex-cell-channels lte 5 455000 10000 315000 10000
```

## Set a single NR cell channel
```
adb shell cmd wifi set-coex-cell-channels nr 78 365000 5000 410000 5000
```

## Set multiple LTE cell channels
```
adb shell cmd wifi set-coex-cell-channels lte 1 450000 8000 310000 8000 lte 2 455000 10000 315000 10000
```

## Set multiple NR cell channels
```
adb shell cmd wifi set-coex-cell-channels nr 55 375000 6000 405000 6000 nr 56 380000 7000 410000 7000
```

## Set a combination of LTE and NR cell channels
```
adb shell cmd wifi set-coex-cell-channels lte 3 460000 12000 320000 12000 nr 70 385000 8000 415000 8000
```

## Set an unknown frequency and bandwidth for a cell channel
```
adb shell cmd wifi set-coex-cell-channels lte 4 UNKNOWN: -1 UNKNOWN: 0 UNKNOWN: -1 UNKNOWN: 0
```

## Start Soft AP with an open network
```
adb shell cmd wifi start-softap <ssid> open
```

## Start Soft AP with a WPA2 network
```
adb shell cmd wifi start-softap <ssid> wpa2 <passphrase>
```

## Start Soft AP with a WPA3 network
```
adb shell cmd wifi start-softap <ssid> wpa3 <passphrase>
```
