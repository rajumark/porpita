# Android ADB Shell getprop Command

## Example Usage
```
adb shell getprop |egrep "model|version.sdk|manufacturer|hardware|platform|revision|serialno|product.name|brand" 2> /dev/null
```

## Check if Knox is voided on an Android device
- If the value is "0", it means Knox is not voided.
- If the value is "1", it means Knox is voided.

```
adb shell getprop ro.boot.warranty_bit
```

## Print CPU abi
```
adb shell getprop ro.product.cpu.abi
```

## Get info if OEM Unlock is Allowed
- 0 = Disabled
- 1 = Enabled

```
adb shell getprop sys.oem_unlock_allowed
```

## Is System boot completed
```
adb shell getprop sys.boot_completed
```
