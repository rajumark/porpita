# Mastering Monkey Testing on Android

## Launch application via monkey
```
adb shell monkey -p com.package -c android.intent.category.LAUNCHER 1
```

## Simulate User Input with Monkey Command
This command specifically targets the package com.package and generates a single event.
```
adb shell monkey --pct-syskeys 0 -p com.package 1
```

## Generate multiple events
```
adb shell monkey -p com.package 500
```

## Generate a particular type of event more often
```
adb shell monkey --pct-touch 70 -p com.package 1000
```

## Generate navigation events more often
```
adb shell monkey --pct-nav 70 -p com.package 1000
```

## Generate trackball events more often
```
adb shell monkey --pct-trackball 70 -p com.package 1000
```

## Generate system level events more often
```
adb shell monkey --pct-syskeys 70 -p com.package 1000
```

## Generate app switch events more often
```
adb shell monkey --pct-appswitch 70 -p com.package 1000
```

## Generate flip events more often
```
adb shell monkey --pct-flip 70 -p com.package 1000
```

## Generate any events excluding syskeys
```
adb shell monkey --pct-syskeys 0 -p com.package 1000
```

## Generate multiple events with delay between each
```
adb shell monkey -p com.package --throttle 1000 1000
```

## Run the monkey command in a verbose mode
```
adb shell monkey -p com.package -v 500
```

## Generate events and collect a log of the command's output
```
adb shell monkey -p com.package -v -v 500 > out.txt
```

## Generate events and show only error logs
```
adb shell monkey -p com.package --monitor-native-crashes 500
```

## Halt Monkey and report the error if any activity fails or crashes
```
adb shell monkey -p com.package --abort-on-error 500
```

## Simulate only touch events
```
adb shell monkey -p com.package --pct-touch 100 500
```

## Simulate only trackball events
```
adb shell monkey -p com.package --pct-trackball 100 500
```

## Simulate only navigation events
```
adb shell monkey -p com.package --pct-nav 100 500
```

## Simulate only system events
```
adb shell monkey -p com.package --pct-syskeys 100 500
```

## Simulate only major navigation events
```
adb shell monkey -p com.package --pct-majornav 100 500
```

## Simulate only app switch events
```
adb shell monkey -p com.package --pct-appswitch 100 500
```

## Simulate only flip events
```
adb shell monkey -p com.package --pct-flip 100 500
```

## Run Monkey command for a specified time
```
adb shell monkey -p com.package --running-time 60 1000
```

## Run Monkey command for a long time with delay between events
```
adb shell monkey -p com.package --throttle 1000 --running-time 600 1000
```

## Simulate events and ignore any crashes
```
adb shell monkey -p com.package --ignore-crashes 500
```

## Simulate events and ignore any timeouts
```
adb shell monkey -p com.package --ignore-timeouts 500
```

## Generate events and ignore security exceptions
```
adb shell monkey -p com.package --ignore-security-exceptions 500
```

## Generate events and ignore any crashes or ANRs
```
adb shell monkey -p com.package --ignore-crashes --ignore-timeouts 500
```

## Generate events and kill the process if a crash/timeout occurs
```
adb shell monkey -p com.package --kill-process-after-error 500
```

## Generate a random number of events
```
adb shell monkey -p com.package --randomize-throttle 500
```

## Use a seed value for the pseudo-random number generator
```
adb shell monkey -p com.package --seed 12345 500
```

## Generate events and stop when a specific error occurs
```
adb shell monkey -p com.package --halt-on-error 500
```

## Specify the categories of events to be generated
```
adb shell monkey -p com.package --pkg-blacklist-file blacklist.txt 500
```

## Specify multiple categories of events to be generated
```
adb shell monkey -p com.package --pkg-whitelist-file whitelist.txt 500
```

## Simulate touch events at specific locations
```
adb shell monkey -p com.package --touch-percentage 70 500
```

## Simulate only system level operations
```
adb shell monkey -p com.package --pct-syskeys 100 500
```

## Simulate events on multiple applications
```
adb shell monkey -p com.package1 -p com.package2 500
```

## Generate a specific number of events for multiple applications
```
adb shell monkey -p com.package1 -p com.package2 1000
```

## Use the network to generate events
```
adb shell monkey -p com.package --network 500
```

## Generate events only on the apps that are permitted to receive the specified permissions
```
adb shell monkey -p com.package --permission android.permission.INTERNET 500
```

## Specify the proportion of "basic" operation events to be generated
```
adb shell monkey -p com.package --pct-anyevent 70 500
```
