# Android Data Management with ADB and Content Providers

## Query settings for system
```
adb shell content query --uri content://settings/system/
```

## View sim info by slot
```
adb shell content query --uri content://com.sec.ims.settings/global#simslot/1
```

## Set vibrator for specific settings/profile
```
adb shell content query --uri content://com.android.settings.personalvibration.PersonalVibrationProvider
```

## List all names of secure settings
```
adb shell content query --uri content://settings/secure/ | awk -F "[=,]" '{print "adb shell content query --uri content://system/settings/"$4}'
```

## Query all settings with gnu parallel
```
echo -e "secure\nsystem\nglobal"| parallel -k -j3 "adb shell content query --uri content://settings/{}"
```

## Disable developer mode
```
adb shell content update --uri content://settings/global --where "name='development_settings_enabled'" --bind value:s:0
```

## Add new setting with content
```
adb shell content insert --uri content://settings/secure --bind name:s:oem_unlock_allowed --bind value:s:1
```

## Change "new_setting" secure setting to "newer_value"
```
adb shell content update --uri content://settings/secure --bind value:s:newer_value --where "name='new_setting'"
```

## Status for developer mode
```
adb shell content query --uri content://settings/global --where "name='development_settings_enabled'"
```

## Find contents in sdk map and create samples for this cheatsheet
```
adb shell "su -c content query --uri content://com.samsung.rcs.autoconfigurationprovider/root/* |tr ' ' '\n'"
```

## Print device number
```
adb shell "su -c content query --uri content://com.samsung.rcs.autoconfigurationprovider/root/application/1/im/fthttpcsuser"
```

## Delete a certain setting
```
adb shell content delete --uri content://settings/secure --where "name='new_setting'"
```

## Insert a setting and value to foo
```
adb shell content insert --uri content://settings/secure --bind name:s:user_setup_complete --bind value:s:1
```

## Change setting to another setting
```
adb shell content update --uri content://settings/secure --bind value:s:newer_value --where "name='new_setting'"
```

## Read will be able to read all kind of file extensions like zip, mp3 etc
```
adb shell 'content read --uri content://settings/system/ringtone_cache' > foo.ogg
```

## Print current type for a content
```
adb shell content gettype --uri content://media/internal/audio/media/
```

## Print all names and mmsproxy
```
adb shell su -c content query --uri content://telephony/carriers/sim_apn_list --projection name:mmsproxy
```

## Print heapdump
```
adb shell content query --uri content://com.android.shell.heapdump/
```

## Print calls
```
adb shell content query --uri content://call_log/calls
```

## Print shadow calls
```
adb shell content query --uri content://call_log_shadow/calls
```

## Print call filters
```
adb shell content query --uri content://call_log/calls/filter
```

## Print call log
```
adb shell content query --uri content://call_log/calls
```

## Print downloads
```
adb shell content query --uri content://downloads/my_downloads
```

## Print all downloads
```
adb shell content query --uri content://downloads/all_downloads
```

## Print current downloads
```
adb shell content query --uri content://downloads/
```

## Print my all live
```
adb shell content query --uri content://my.app/live
```

## Print sms changes
```
adb shell content query --uri content://sms-changes
```

## Print sms
```
adb shell content query --uri content://sms
```

## Print sms inbox
```
adb shell content query --uri content://sms/inbox
```

## Print sms sent
```
adb shell content query --uri content://sms/sent
```

## Print sms draft messages
```
adb shell content query --uri content://sms/draft
```

## Print sms outbox
```
adb shell content query --uri content://sms/outbox
```

## Print sms conversations
```
adb shell content query --uri content://sms/conversations
```

## Print carrier information
```
adb shell content query --uri content://carrier_information/carrier
```

## Print mms ids
```
adb shell content query --uri content://mms-sms/threadID
```

## Print mms
```
adb shell content query --uri content://mms
```

## Print mms inbox
```
adb shell content query --uri content://mms/inbox
```

## Print sent mms
```
adb shell content query --uri content://mms/sent
```

## Print mms drafts
```
adb shell content query --uri content://mms/drafts
```

## Print mms outbox
```
adb shell content query --uri content://mms/outbox
```

## Print mms via sms
```
adb shell content query --uri content://mms-sms/
```

## Print mms via sms conversation
```
adb shell content query --uri content://mms-sms/conversations
```

## Print mms via sms by phone
```
adb shell content query --uri content://mms-sms/messages/byphone
```

## Print undelivered mms via sms
```
adb shell content query --uri content://mms-sms/undelivered
```

## Print drafted mms via sms
```
adb shell content query --uri content://mms-sms/draft
```

## Print locked mms via sms
```
adb shell content query --uri content://mms-sms/locked
```

## Print search results for mms via sms
```
adb shell content query --uri content://mms-sms/search
```

## Print device carriers
```
adb shell su -c content query --uri content://telephony/carriers
```

## Print device carriers apn list for simcard
```
adb shell su -c content query --uri content://telephony/carriers/sim_apn_list --projection name:mmsproxy
```

## Print device carriers dpc
```
adb shell content query --uri content://telephony/carriers/dpc
```

## Print device carriers filtered
```
adb shell content query --uri content://telephony/carriers/filtered
```

## Print device carriers enforce manage
```
adb shell content query --uri content://telephony/carriers/enforce_managed
```

## Print device preferapnset subids
```
adb shell content query --uri content://telephony/carriers/preferapn/subId
```

## Print device preferapnset subid
```
adb shell content query --uri content://telephony/carriers/preferapnset/subId
```

## Print cellbroadcasts
```
adb shell content query --uri content://cellbroadcasts
```

## Print cellbroadcasts history
```
adb shell content query --uri content://cellbroadcasts/history
```

## Print cellbroadcasts legacy
```
adb shell content query --uri content://cellbroadcast-legacy
```

## Print cellbroadcasts service state
```
adb shell content query --uri content://service-state/
```

## Print cellbroadcasts carrier-id
```
adb shell content query --uri content://carrier_id
```

## Print cellbroadcasts all info about carrier-id
```
adb shell content query --uri content://carrier_id/all
```

## Print cellbroadcasts simcard info
```
adb shell content query --uri content://telephony/siminfo
```

## Print all contact settings available
```
adb shell content query --uri content://contacts/settings
```

## Contact list
```
adb shell content query --uri content://contacts/people
```

## Print contacts by filter
```
adb shell content query --uri content://contacts/people/filter
```

## Print deleted contacts
```
adb shell content query --uri content://contacts/deleted_people
```

## Print contacts that has an email of im id added
```
adb shell content query --uri content://contacts/people/with_email_or_im_filter
```

## Print contact group
```
adb shell content query --uri content://contacts/groups
```

## Print deleted contact groups
```
adb shell content query --uri content://contacts/deleted_groups
```

## Print all phone numbers
```
adb shell content query --uri content://contacts/phones
```

## Print all phone number filters
```
adb shell content query --uri content://contacts/phones/filter
```

## Print all group memberships
```
adb shell content query --uri content://contacts/groupmembership
```

## Print all contacts groupmemberships in raw format
```
adb shell content query --uri content://contacts/groupmembershipraw
```

## Print contact methods
```
adb shell content query --uri content://contacts/contact_methods
```

## Print contacts email address
```
adb shell content query --uri content://contacts/contact_methods/email
```

## Print contacts presence
```
adb shell content query --uri content://contacts/presence
```

## Print contacts organizations
```
adb shell content query --uri content://contacts/organizations
```

## Print contacts photo path
```
adb shell content query --uri content://contacts/photos
```

## Print contacts extensions
```
adb shell content query --uri content://contacts/extensions
```

## Get google contacts with full info
```
adb shell content query --uri content://com.android.contacts/data --projection display_name:data1:data4:contact_id
```

## Get google contacts and print notes for every contact
```
adb shell content query --uri content://contacts/phones/ --projection display_name:number:notes
adb shell content query --uri content://contacts/people/
```

## Count people in contact list
```
adb shell bash content query --uri content://contacts/people/ |wc -l
```

## List the phone numbers
```
adb shell content query --uri content://contacts/phones/
```

## List the groups
```
adb shell content query --uri content://contacts/groups/
```

## List group membership
```
adb shell content query --uri content://contacts/groupmembership/
```

## List organizations
```
adb shell content query --uri content://contacts/organizations/
```

## Trick device that setup already has been done (FRP Bypassing)
```
adb shell content insert --uri content://settings/secure --bind name:s:user_setup_complete --bind value:s:1
adb shell am start -n com.google.android.gsf.login/
adb shell am start -n com.google.android.gsf.login.LoginActivity
```

## Dump global settings
```
adb shell content query --uri content://settings/global
```

## Dump secure settings
```
adb shell content query --uri content://settings/secure
```

## Print target dir to all applications settings dir that can be edited manually
```
adb shell content query --uri content://media/external/file --projection _data
```

## Query secure settings Select "name" and value columns from secure settings where name is equal to new_setting and sort the result by name in ascending order
```
adb shell content query --uri content://settings/secure --projection name:value
```

## Remove "new_setting" secure setting
```
adb shell content delete --uri content://settings/secure --where "name='new_setting'"
```

## Download current ringtone and play on PC via ffplay
```
content read --uri content://settings/system/ringtone_cache' > a.ogg |xargs ffplay a.ogg
```

## Auto rotation on
```
adb shell content insert --uri content://settings/system --bind name:s:accelerometer_rotation --bind value:i:1
```

## Auto rotation off
```
adb shell content insert --uri content://settings/system --bind name:s:accelerometer_rotation --bind value:i:0
```

## Rotate to landscape
```
adb shell content insert --uri content://settings/system --bind name:s:user_rotation --bind value:i:1
```

## Rotate portrait
```
adb shell content insert --uri content://settings/system --bind name:s:user_rotation --bind value:i:0
```
