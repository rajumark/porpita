# Navigating the Android Sysfs

## Sysfs Commands

## Dump everything that will trigger the LED, section 1
```
cat /sys/class/leds/leds-sec1/trigger
```

## Dump temperature for sensors that support this feature
```
grep . /sys/class/sensors/*/temperature
```

## Dump ID name for all sensors
```
grep . /sys/class/sensors/*/name
```

## Dump settings for FOTA limits
```
cat /sys/power/fota_limit
```

## Dump current state values
```
cat /sys/power/state
```

## Dump version of firmware, DHD, NV, and CLM
```
cat /sys/wifi/wifiver
```

## Dump wifi MAC address
```
echo $(cat /sys/wifi/mac_addr)
```

## Dump roaming status for wifi (read-only from sysfs)
```
cat /sys/wifi/roamoff
```

## Set display brightness to darkest
```
echo 1 > /sys/class/backlight/panel/brightness
```

## Set display brightness max (default)
```
echo 255 > /sys/class/backlight/panel/brightness
```

## Dump current setting for USB mode
```
cat /sys/devices/soc0/hw_platform
```

## Dump all kernel drivers supported for device
```
ls /sys/bus/usb/drivers/
```

## Print current panel alias
```
cat /sys/devices/platform/panel_0/modalias
```
