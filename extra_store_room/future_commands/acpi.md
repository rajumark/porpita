# ACPI Commands for Android

## Battery Percentage Retrieval Example
```
adb shell acpi 2> /dev/null
```

## Cooling Device State Illustration
```
adb shell 'su -c acpi -c'
```

## Thermal Temperature Demonstration
```
adb shell 'su -c acpi -t'
```

## Sensors Display via acpi
```
adb shell acpi -V
```

## Battery Information and Usage Showcase
```
adb shell acpi -b
```

## Power Source Information Overview
```
adb shell acpi -a
```

## Fan Speed Display
```
adb shell acpi -f
```
