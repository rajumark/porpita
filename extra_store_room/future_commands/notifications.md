# Elevating Android Notification Experience

## Send notification with a big text style
```
adb shell su -lp 2000 -c "cmd notification post -S bigtext -t 'adb pwnz' 'Tag' 'it rly does'"
```

## Allow notification listener
```
adb shell su -lp 2000 -c "cmd notification allow_listener COMPONENT [user_id]"
```

## Disallow notification listener
```
adb shell su -lp 2000 -c "cmd notification disallow_listener COMPONENT [user_id]"
```

## Allow notification assistant
```
adb shell su -lp 2000 -c "cmd notification allow_assistant COMPONENT [user_id]"
```

## Remove notification assistant
```
adb shell su -lp 2000 -c "cmd notification remove_assistant COMPONENT [user_id]"
```

## Configure Do Not Disturb (DND) settings
```
adb shell su -lp 2000 -c "cmd notification set_dnd [on|none|priority|alarms|all|off] allow_dnd PACKAGE [user_id]"
```

## Reset notification assistant settings
```
adb shell su -lp 2000 -c "cmd notification reset_assistant_user_set [user_id]"
```

## Disallow Do Not Disturb (DND) override
```
adb shell su -lp 2000 -c "cmd notification disallow_dnd PACKAGE [user_id]"
```

## Retrieve notification details
```
adb shell su -lp 2000 -c "cmd notification get <notification-key>"
```

## Snooze notification
```
adb shell su -lp 2000 -c "cmd notification snooze --for <msec> <notification-key>"
```

## List all notifications
```
adb shell cmd notification list
```

## Set bubble notifications for a channel
```
adb shell su -lp 2000 -c "cmd notification set_bubbles_channel PACKAGE CHANNEL_ID ALLOW [user_id]"
```

## Set bubble notification preferences
```
adb shell su -lp 2000 -c "cmd notification set_bubbles PACKAGE PREFERENCE [user_id]"
```

## Post a notification
```
adb shell su -lp 2000 -c "cmd notification post [--help | flags] TAG TEXT"
```

## Get approved notification assistant
```
adb shell su -lp 2000 -c "cmd notification get_approved_assistant [user_id]"
```

## Unsnooze a Previously Snoozed Notification
```
adb shell su -lp 2000 -c "cmd notification unsnooze <notification-key>"
```
