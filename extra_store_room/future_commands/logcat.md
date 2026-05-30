# Navigating the Depths of Android Logcat

## Advanced Logcat Commands

All commands/scripts in this section is done by wuseman

## Highlight Specific String in adb logcat Output Using Custom Colors
```
adb logcat | awk '{ gsub("telia", "\033[1;31m\033[47mT\033[32m\033[33me\033[34ml\033[1;36mi\033[1;35ma\033[0m") print }'
```

## Highlight specific strings in adb logcat Output Using Custom Colors
```
adb logcat | awk '{ gsub("telia", "\033[1;31m\033[47mT\033[32m\033[33me\033[34ml\033[1;36mi\033[1;35ma\033[0m") gsub("wifi", "\033[1;33m\033[47mW\033[32m\033[33mi\033[34mf\033[1;36mi\033[1;35ma\033[0m") print }'
```

## Logcat application by pid
```
adb shell su -c logcat --pid=$(adb shell su -c ps -A|grep -i com.sec.android.app.parser|awk '{print $2}')
```

## Filter logs by specific tag name
```
adb logcat -s "tagname"
```

## Filter multiple tags
```
adb logcat ActivityManager:I MyApp:D *:S
```

## Redirect output to a file
```
adb logcat > myfile.txt
```

## Use grep for filtering
```
adb logcat | grep "tagname"
```

## Rotate Logs
```
adb logcat -f /sdcard/myapp.log -r 5000 -n 10
```

## Print colored output
```
adb logcat -C
```

## Regex filter
```
adb logcat | grep -E '^(?=.*Exception)(?=.*Activity)'
```

## Printing Log Entries Related to Lock Settings
```
adb logcat| grep "LockSettingsService\|LockPatternUtilsKeyStorage\|vold\|vold\|keystore2\|keymaster_tee\|LockSettingsService\|vold_prepare_subdirs"
```

## Highlight Matched Lines by Red Background
```
adb logcat | awk ' { line = tolower($0) if (line ~ /key/) { printf "\033[41m%s\033[0m\n", $0 } else { print } } '
```

## Create SubSettings Commands
```
adb logcat | grep -i "SecTileUtils: Found" | awk '{ match($0, /Found ([^ ]+) for intent/, arr) if (arr[1]) { gsub(/\$/, "\\$", arr[1]) # Escape dollar signs sub(/com.android.settings/, "com.android.settings/", arr[1]) printf "adb shell am start -n '%s'\n", arr[1] } }'
```

## Create adb shell commands for received broadcasts
```
adb logcat | awk ' /Received BROADCAST.*SCREEN_ON/ { match($0, /pkg=[^ ]+/, pkgArr) match($0, /act=[^ ]+/, actArr) match($0, /cmp=[^ ]+/, cmpArr) if (pkgArr[0] && actArr[0] && cmpArr[0]) { pkg = substr(pkgArr[0], 5) act = substr(actArr[0], 5) cmp = substr(cmpArr[0], 5) printf "adb shell am broadcast -a \033[1;33m'%s'\033[0m -n \033[1;36m'%s'\033[0m\n", act, cmp } }'
```

## Custom Timestamp Format for adb logcat
```
adb logcat -v brief | while read -r line; do echo "$(date +"[%Y-%m-%d|%H:%M:%S]")-$line" done
```
