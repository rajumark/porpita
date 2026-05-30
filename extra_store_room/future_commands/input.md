# Mastering ADB Input Commands

## To tap on the center of the screen
```
adb shell input tap 250 1150
```

## To tap on the Power button
```
adb shell input tap 150 350
```

## To tap on the top-right corner of the screen
```
adb shell input tap 500 0
```

## To tap on the bottom-left corner of the screen
```
adb shell input tap 0 2300
```

## To tap on the middle-left of the screen
```
adb shell input tap 100 1150
```

## To tap on the middle-right of the screen
```
adb shell input tap 400 1150
```

## To simulate a swipe from the middle of the screen to the top (useful for scrolling)
```
adb shell input swipe 250 1150 250 300
```

## To simulate a swipe from the middle of the screen to the bottom (also for scrolling)
```
adb shell input swipe 250 1150 250 2000
```

## To simulate a long press at the middle of the screen (for context menus or similar functionality)
```
adb shell input swipe 250 1150 250 1150 2000
```

## To simulate a pinch gesture (zoom out), we can use two swipe commands that start from different points and converge in the middle of the screen
```
adb shell input swipe 100 1000 250 1150 & adb shell input swipe 400 1300 250 1150
```

## To simulate a spread gesture (zoom in), we can use two swipe commands that start from the same point in the middle of the screen and move towards different ends
```
adb shell input swipe 250 1150 100 1000 & adb shell input swipe 250 1150 400 1300
```

## Tap on the top-left corner of the screen
```
adb shell input tap 0 0
```

## Tap on the bottom-right corner of the screen
```
adb shell input tap 500 2300
```

## Simulate a swipe from the bottom to the top of the screen (reverse scrolling)
```
adb shell input swipe 250 2000 250 300
```

## Simulate a swipe from top to the bottom of the screen (reverse scrolling)
```
adb shell input swipe 250 300 250 2000
```

## Simulate a long press at the top-left of the screen
```
adb shell input swipe 0 0 0 0 2000
```

## Simulate a long press at the bottom-right of the screen
```
adb shell input swipe 500 2300 500 2300 2000
```

## Simulate a drag gesture from the middle of the screen to the top-right
```
adb shell input swipe 250 1150 500 0
```

## To simulate a drag gesture from the middle of the screen to the bottom-left
```
adb shell input swipe 250 1150 0 2300
```

## To tap on a point in the upper-middle section of the screen
```
adb shell input tap 250 600
```

## To tap on a point in the lower-middle section of the screen
```
adb shell input tap 250 1800
```

## To simulate a swipe diagonally from the top-left to the bottom-right of the screen
```
adb shell input swipe 0 0 500 2300
```

## To simulate a swipe diagonally from the top-right to the bottom-left of the screen
```
adb shell input swipe 500 0 0 2300
```

## To simulate a swipe diagonally from the bottom-left to the top-right of the screen
```
adb shell input swipe 0 2300 500 0
```

## To simulate a swipe diagonally from the bottom-right to the top-left of the screen
```
adb shell input swipe 500 2300 0 0
```

## To simulate a swipe from left to right across the screen (useful for going to the next item in a carousel)
```
adb shell input swipe 0 1150 500 1150
```

## To simulate a swipe from right to left across the screen (useful for going to the previous item in a carousel)
```
adb shell input swipe 500 1150 0 1150
```

## To simulate a tap on the "Back" button area (assuming it's at the bottom-left of the screen)
```
adb shell input tap 100 2200
```

## To simulate a tap on the "Home" button area (assuming it's at the bottom-middle of the screen)
```
adb shell input tap 250 2200
```

## To simulate a tap on the "Recent Apps" button area (assuming it's at the bottom-right of the screen)
```
adb shell input tap 400 2200
```

## To simulate a swipe from the "Recent Apps" button to the middle of the screen (useful for opening the recent apps view)
```
adb shell input swipe 400 2200 250 1150
```

## To simulate a swipe from the top to the middle of the screen (useful for pulling down the notification shade)
```
adb shell input swipe 250 0 250 600
```

## To simulate a swipe from the middle to the top of the screen (useful for pushing up the notification shade)
```
adb shell input swipe 250 600 250 0
```

## To simulate a long press on the "Home" button (useful for triggering Google Assistant or any other bound service)
```
adb shell input swipe 250 2200 250 2200 2000
```

## To simulate a tap on the upper-middle-left of the screen (might be useful for some apps)
```
adb shell input tap 150 600
```

## To simulate a tap on the upper-middle-right of the screen (might be useful for some apps)
```
adb shell input tap 350 600
```

## To simulate a tap on the lower-middle-left of the screen (might be useful for some apps)
```
adb shell input tap 150 1800
```

## To simulate a tap on the lower-middle-right of the screen (might be useful for some apps)
```
adb shell input tap 350 1800
```

## To simulate a long press in the upper-middle-left of the screen
```
adb shell input swipe 150 600 150 600 2000
```

## To simulate a long press in the upper-middle-right of the screen
```
adb shell input swipe 350 600 350 600 2000
```

## To simulate a long press in the lower-middle-left of the screen
```
adb shell input swipe 150 1800 150 1800 2000
```

## To simulate a long press in the lower-middle-right of the screen
```
adb shell input swipe 350 1800 350 1800 2000
```

## To simulate a diagonal swipe from upper-middle-left to lower-middle-right of the screen
```
adb shell input swipe 150 600 350 1800
```

## To simulate a diagonal swipe from upper-middle-right to lower-middle-left of the screen
```
adb shell input swipe 350 600 150 1800
```

## To simulate a diagonal swipe from lower-middle-left to upper-middle-right of the screen
```
adb shell input swipe 150 1800 350 600
```

## To simulate a diagonal swipe from lower-middle-right to upper-middle-left of the screen
```
adb shell input swipe 350 1800 150 600
```

## To simulate a tap on the center of the status bar (useful for some quick settings)
```
adb shell input tap 250 50
```

## To simulate a tap on the center of the antenna area (might be useful for some games or full-screen apps)
```
adb shell input tap 250 2250
```

## To simulate a swipe from the center of the antenna area to the center of the screen (useful for some games or full-screen apps)
```
adb shell input swipe 250 2250 250 1150
```

## To simulate a swipe from the center of the status bar to the center of the screen (useful for pulling down the notification shade)
```
adb shell input swipe 250 50 250 1150
```

## To simulate a "zig-zag" swipe from the top-left to the bottom-right of the screen
```
adb shell input swipe 0 0 250 1150 & adb shell input swipe 250 1150 500 2300
```

## To simulate a "zig-zag" swipe from the top-right to the bottom-left of the screen
```
adb shell input swipe 500 0 250 1150 & adb shell input swipe 250 1150 0 2300
```

## To simulate a pinch gesture at the top of the screen
```
adb shell input swipe 100 300 250 450 & adb shell input swipe 400 300 250 450
```

## To simulate a spread gesture at the top of the screen
```
adb shell input swipe 250 450 100 300 & adb shell input swipe 250 450 400 300
```

## To simulate a pinch gesture at the bottom of the screen
```
adb shell input swipe 100 2000 250 1850 & adb shell input swipe 400 2000 250 1850
```

## To simulate a spread gesture at the bottom of the screen
```
adb shell input swipe 250 1850 100 2000 & adb shell input swipe 250 1850 400 2000
```

## To simulate a complex gesture (like drawing an "X" from corner to corner)
```
adb shell input swipe 0 0 500 2300 & adb shell input swipe 500 0 0 2300
```

## To simulate a long press in the middle and then a swipe to the right (useful for triggering slide menus)
```
adb shell input swipe 250 1150 250 1150 1000 & adb shell input swipe 250 1150 400 1150
```

## To simulate a long press in the middle and then a swipe to the left (useful for triggering slide menus)
```
adb shell input swipe 250 1150 250 1150 1000 & adb shell input swipe 250 1150 100 1150
```

## To simulate a swipe from the center of the screen to the "Back" button (might be useful for some full-screen apps)
```
adb shell input swipe 250 1150 100 2200
```

## To simulate a swipe from the center of the screen to the "Home" button (might be useful for some full-screen apps)
```
adb shell input swipe 250 1150 250 2200
```

## To simulate a swipe from the center of the screen to the "Recent Apps" button (might be useful for some full-screen apps)
```
adb shell input swipe 250 1150 400 2200
```

## To simulate a long press on the top-middle of the screen (might be useful for some apps)
```
adb shell input swipe 250 600 250 600 2000
```

## To simulate a long press on the bottom-middle of the screen (might be useful for some apps)
```
adb shell input swipe 250 1800 250 1800 2000
```

## To simulate a pinch gesture in the left-half of the screen
```
adb shell input swipe 50 1000 150 1150 & adb shell input swipe 200 1300 150 1150
```

## To simulate a spread gesture in the left-half of the screen
```
adb shell input swipe 150 1150 50 1000 & adb shell input swipe 150 1150 200 1300
```

## To simulate a pinch gesture in the right-half of the screen
```
adb shell input swipe 300 1000 350 1150 & adb shell input swipe 450 1300 350 1150
```

## To simulate a spread gesture in the right-half of the screen
```
adb shell input swipe 350 1150 300 1000 & adb shell input swipe 350 1150 450 1300
```

## To simulate a swipe in the shape of a square (might be useful for some games or apps)
```
adb shell input swipe 100 1000 400 1000 & adb shell input swipe 400 1000 400 1300 & adb shell input swipe 400 1300 100 1300 & adb shell input swipe 100 1300 100 1000
```

## To simulate a tap on the center of the screen with a delay (useful for timed inputs)
```
sleep 2 && adb shell input tap 250 1150
```

## To simulate multiple taps on the center of the screen with a delay between each (useful for timed inputs)
```
for i in {1..5}; do adb shell input tap 250 1150; sleep 0.5; done
```

## To simulate a swipe from the middle to the left of the screen (useful for some slide menus)
```
adb shell input swipe 250 1150 100 1150
```

## To simulate a swipe from the middle to the right of the screen (useful for some slide menus)
```
adb shell input swipe 250 1150 400 1150
```

## To simulate a swipe from the left to the middle of the screen (useful for some slide menus)
```
adb shell input swipe 100 1150 250 1150
```

## To simulate a swipe from the right to the middle of the screen (useful for some slide menus)
```
adb shell input swipe 400 1150 250 1150
```

## To simulate a swipe from the "Back" button to the "Home" button (useful for some full-screen apps)
```
adb shell input swipe 100 2200 250 2200
```

## To simulate a swipe from the "Home" button to the "Recent Apps" button (useful for some full-screen apps)
```
adb shell input swipe 250 2200 400 2200
```

## To simulate a swipe from the "Recent Apps" button to the "Home" button (useful for some full-screen apps)
```
adb shell input swipe 400 2200 250 2200
```

## To simulate a swipe from the "Home" button to the "Back" button (useful for some full-screen apps)
```
adb shell input swipe 250 2200 100 2200
```

## To simulate a long press on the "Recent Apps" button (useful for some services)
```
adb shell input swipe 400 2200 400 2200 2000
```
