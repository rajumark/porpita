# Advanced Android Permissions Management

## Enable Mock Location
```
adb shell cmd appops set 0 androidmock_location allow
```

## Set Application Run in Background Behavior
```
adb shell cmd appops set com.android.settings RUN_IN_BACKGROUND ignore
```

## Set Any Application Run in Background Behavior
```
adb shell cmd appops set com.android.settings RUN_ANY_IN_BACKGROUND ignore
```

## Set Application to Launch in Foreground
```
adb shell cmd appops set com.android.settings START_FOREGROUND ignore
```

## Set Application Settings for Instant Launch in Foreground
```
adb shell cmd appops set com.android.settings INSTANT_APP_START_FOREGROUND ignore
```

## Set Application Permission for Clipboard
```
adb shell cmd appops set com.android.settings READ_CLIPBOARD allow
```

## Set Application Permission for Writing Clipboard
```
adb shell cmd appops set com.android.settings WRITE_CLIPBOARD allow
```

## Set Application Permission for Read SMS
```
adb shell cmd appops set com.android.settings READ_SMS allow
```

## Set Application Permission for Send SMS
```
adb shell cmd appops set com.android.settings SEND_SMS allow
```

## Set Application Permission for Receive SMS
```
adb shell cmd appops set com.android.settings RECEIVE_SMS allow
```

## Set Application Permission for Location Access
```
adb shell cmd appops set com.android.settings ACCESS_FINE_LOCATION allow
```

## Set Application Permission for Camera Access
```
adb shell cmd appops set com.android.settings CAMERA allow
```

## Set Application Permission for Microphone Access
```
adb shell cmd appops set com.android.settings RECORD_AUDIO allow
```

## Set Application Permission for Read Contacts
```
adb shell cmd appops set com.android.settings READ_CONTACTS allow
```

## Set Application Permission for Write Contacts
```
adb shell cmd appops set com.android.settings WRITE_CONTACTS allow
```

## Set Application Permission for Read Call Log
```
adb shell cmd appops set com.android.settings READ_CALL_LOG allow
```

## Set Application Permission for Write Call Log
```
adb shell cmd appops set com.android.settings WRITE_CALL_LOG allow
```

## Set Application Permission for Read Calendar
```
adb shell cmd appops set com.android.settings READ_CALENDAR allow
```

## Set Application Permission for Write Calendar
```
adb shell cmd appops set com.android.settings WRITE_CALENDAR allow
```

## Set Application Permission for Read Storage
```
adb shell cmd appops set com.android.settings READ_EXTERNAL_STORAGE allow
```

## Set Application Permission for Write Storage
```
adb shell cmd appops set com.android.settings WRITE_EXTERNAL_STORAGE allow
```

## Set Application Permission for Read Phone State
```
adb shell cmd appops set com.android.settings READ_PHONE_STATE allow
```

## Set Application Permission for Make Phone Calls
```
adb shell cmd appops set com.android.settings CALL_PHONE allow
```

## Set Application Permission for Read Logs
```
adb shell cmd appops set com.android.settings READ_LOGS allow
```

## Set Application Permission for Change Network State
```
adb shell cmd appops set com.android.settings CHANGE_NETWORK_STATE allow
```

## Set Application Permission for Use Fingerprint
```
adb shell cmd appops set com.android.settings USE_FINGERPRINT allow
```

## Set Application Permission for Accept Handover
```
adb shell cmd appops set com.android.settings ACCEPT_HANDOVER allow
```

## Set Application Permission for Read Calendar Events
```
adb shell cmd appops set com.android.settings READ_CALENDAR allow
```

## Set Application Permission for Write Calendar Events
```
adb shell cmd appops set com.android.settings WRITE_CALENDAR allow
```

## Set Application Permission for Read Clipboard
```
adb shell cmd appops set com.android.settings READ_CLIPBOARD allow
```

## Set Application Permission for Write Clipboard
```
adb shell cmd appops set com.android.settings WRITE_CLIPBOARD allow
```

## Set Application Permission for Read Usage Stats
```
adb shell cmd appops set com.android.settings USAGE_STATS allow
```

## Set Application Permission for Answer Phone Calls
```
adb shell cmd appops set com.android.settings ANSWER_PHONE_CALLS allow
```

## Set Application Permission for Access Call Logs
```
adb shell cmd appops set com.android.settings READ_CALL_LOG allow
```

## Set Application Permission for Read Voicemail
```
adb shell cmd appops set com.android.settings READ_VOICEMAIL allow
```

## Set Application Permission for Write Voicemail
```
adb shell cmd appops set com.android.settings WRITE_VOICEMAIL allow
```

## Set Application Permission for Use SIP
```
adb shell cmd appops set com.android.settings USE_SIP allow
```

## Set Application Permission for Read SIP Settings
```
adb shell cmd appops set com.android.settings READ sip_SETTINGS allow
```

## Set Application Permission for Write SIP Settings
```
adb shell cmd appops set com.android.settings WRITE_SIP_SETTINGS allow
```

## Set Application Permission for Use VoIP
```
adb shell cmd appops set com.android.settings USE_VOIP allow
```

## Find available modes
```
adb shell cmd appops query-ops
```

## Get the status of Location Access permission for Google Maps
```
adb shell cmd appops get com.google.android.gms.maps ACCESS_FINE_LOCATION
```

## Get the status of Camera permission for Google Photos
```
adb shell cmd appops get com.google.android.apps.photos CAMERA
```

## Get the status of Microphone permission for Google Assistant
```
adb shell cmd appops get com.google.android.apps.googleassistant RECORD_AUDIO
```

## Get the status of Read Contacts permission for Google Contacts
```
adb shell cmd appops get com.google.android.contacts READ_CONTACTS
```

## Get the status of Write Contacts permission for Google Contacts
```
adb shell cmd appops get com.google.android.contacts WRITE_CONTACTS
```

## Get the status of Read Calendar permission for Google Calendar
```
adb shell cmd appops get com.google.android.calendar READ_CALENDAR
```

## Get the status of Write Calendar permission for Google Calendar
```
adb shell cmd appops get com.google.android.calendar WRITE_CALENDAR
```

## Get the status of Read Storage permission for Google Drive
```
adb shell cmd appops get com.google.android.apps.docs READ_EXTERNAL_STORAGE
```

## Get the status of Write Storage permission for Google Drive
```
adb shell cmd appops get com.google.android.apps.docs WRITE_EXTERNAL_STORAGE
```

## Get the status of Read Phone State permission for Google Phone
```
adb shell cmd appops get com.google.android.dialer READ_PHONE_STATE
```

## Get the status of Location Access permission for Google Chrome
```
adb shell cmd appops get com.android.chrome ACCESS_FINE_LOCATION
```

## Query App Operation Status
```
adb shell cmd appops query-ops
```
