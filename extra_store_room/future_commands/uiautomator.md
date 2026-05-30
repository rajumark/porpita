# Uiautomator: Extract IMEI from e-SIM

## Print IMEI from e-SIM (the only known method as of now, please contribute if you know more)
```
#!/bin/bash
# Author: wuseman
adb shell input keyevent KEYCODE_CALL; sleep 1; input text '*#06#'; uiautomator dump --compressed /dev/stdout \
| tr ' ' '\n' \
| awk -F'"' '{print $2}' \
| grep "^[0-9]\{15\}$" \
| nl -w 1 -s':' \
| sed 's/^/IMEI/g'
```
