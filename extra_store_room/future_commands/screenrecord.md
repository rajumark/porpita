# Screenrecord

## Basic Usage
This command records the screen and saves the video file as "record.mp4" in the device's internal storage directory.
```
adb shell screenrecord /sdcard/record.mp4
```

## Specify Recording Time
This command records the screen for 30 seconds and saves the video file as "record.mp4" in the device's internal storage directory. You can modify the duration according to your requirements.
```
adb shell screenrecord --time-limit 30 /sdcard/record.mp4
```

## Set Video Size and Bitrate
This command records the screen with a video size of 1280x720 pixels and a bitrate of 8 Mbps. The recorded video is saved as "record.mp4" in the device's internal storage directory. You can adjust the size and bitrate values based on your needs.
```
adb shell screenrecord --size 1280x720 --bit-rate 8000000 /sdcard/record.mp4
```

## Record with Audio
This command records the screen along with audio and saves the video file as "record.mp4" in the device's internal storage directory. Note that not all devices support audio recording, and the audio quality may vary.
```
adb shell screenrecord --audio /sdcard/record.mp4
```

## Show Taps on the Screen
This command records the screen and displays taps as visual indicators on the recorded video. The video file is saved as "record.mp4" in the device's internal storage directory.
```
adb shell screenrecord --show-touches /sdcard/record.mp4
```

## Change Recording Orientation
This command records the screen in landscape orientation. You can specify either "landscape" or "portrait" as the orientation value.
```
adb shell screenrecord --orientation landscape /sdcard/record.mp4
```

## Specify Time Limit and Size
This command records the screen for 60 seconds with a video size of 1920x1080 pixels. The recorded video is saved as "record.mp4" in the device's internal storage directory.
```
adb shell screenrecord --time-limit 60 --size 1920x1080 /sdcard/record.mp4
```

## Record Screen to Different Directory
This command records the screen for 60 seconds with a video size of 1920x1080 pixels. The recorded video is saved as "record.mp4" in the device's internal storage directory.
```
adb shell screenrecord --output /sdcard/recordings/record.mp4
```

## Record Screen with Delayed Start
This command adds a delay of 5 seconds before starting the screen recording. It allows you to prepare the screen or perform any necessary actions before the recording begins.
```
adb shell screenrecord --delay 5 /sdcard/record.mp4
```

## Set Maximum Recording Size
This command sets the maximum file size for the screen recording to 10 MB (10,000,000 bytes). Once the file reaches this size, the recording automatically stops. You can adjust the maximum size value based on your storage capacity and requirements.
```
adb shell screenrecord --size 1280x720 --max-size 10000000 /sdcard/record.mp4
```

## Show Touches with a Colored Circle
This command displays touches on the screen as a colored circle during the screen recording. It provides a visual indication of touch input on the recorded video.
```
adb shell screenrecord --show-touches /sdcard/record.mp4
```

## Record Screen with Custom Time Format
This command sets the time format for the screen recording file name to "hh:ss" (hours:minutes:seconds). The resulting video file will have the time information appended to its name, allowing for better organization and identification.
```
adb shell screenrecord --time-format hh:mm:ss /sdcard/record.mp4
```
