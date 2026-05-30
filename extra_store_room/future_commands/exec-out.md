# Android ADB Shell Exec-out Streaming

## Stream via Preferred Tool
```
adb shell screenrecord --output-format=h264 - | mplayer -framedrop -fps 6000 -cache 512 -demuxer h264es -
```

## Stream via mplayer
```
adb exec-out screenrecord --bit-rate=16m --output-format=h264 --size 1280x720 - | mplayer -demuxer h264es -fps 60 -
```
