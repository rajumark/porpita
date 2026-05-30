# Navigating Android Package Management

## Print this help text
```
adb shell pm help
```

## Print the path to the .apk of the given PACKAGE
```
adb shell pm path --user 0 com.android.settings
```

## Print various system state associated with the given PACKAGE
```
adb shell pm dump com.android.settings
```

## Prints true and returns exit status 0 when the system has a FEATURE_NAME, otherwise prints false and returns exit status 1
```
adb shell pm has-feature FEATURE_NAME [version]
```

## Prints all features of the system
```
adb shell pm list features
```

## Prints all test packages; optionally only those targeting TARGET-PACKAGE
```
adb shell pm list instrumentation [-f] [TARGET-PACKAGE]
```

## Prints all system libraries
```
adb shell pm list libraries
```

## Prints all packages and their associated files
```
adb shell pm list packages -f
```

## Prints all known packages, excluding APEXes
```
adb shell pm list packages
```

## Filters and shows only disabled packages
```
adb shell pm list packages -d
```

## Filters and shows only enabled packages
```
adb shell pm list packages -e
```

## Filters and shows only system packages
```
adb shell pm list packages -s
```

## Filters and shows only third-party packages
```
adb shell pm list packages -3
```

## Shows the installer for the packages
```
adb shell pm list packages -i
```

## Also shows the package UID
```
adb shell pm list packages -U
```

## Includes uninstalled packages
```
adb shell pm list packages -u
```

## Also shows the version code
```
adb shell pm list packages --show-versioncode
```

## Only shows APEX packages
```
adb shell pm list packages --apex-only
```

## Filters and shows packages with the given UID
```
adb shell pm list packages --uid UID
```

## Only lists packages belonging to the given user
```
adb shell pm list packages --user USER_ID
```

## Prints all known permission groups
```
adb shell pm list permission-groups
```

## List all permissions
```
adb shell pm list permissions
```

## List permissions and their groups
```
adb shell pm list permissions -g
```

## List only system permissions
```
adb shell pm list permissions -s
```

## List only disabled permissions
```
adb shell pm list permissions -d
```

## List only user permissions
```
adb shell pm list permissions -u
```

## List all staged sessions
```
adb shell pm list staged-sessions
```

## List only ready staged sessions
```
adb shell pm list staged-sessions --ready
```

## List only session IDs of staged sessions
```
adb shell pm list staged-sessions --session-id-only
```

## List only parent staged sessions
```
adb shell pm list staged-sessions --parent-only
```

## List Users
```
adb shell pm list users
```

## Prints the activity that resolves to the given INTENT
```
adb shell pm resolve-activity INTENT
```

## Prints all activities that can handle the given INTENT
```
adb shell pm query-activities INTENT
```

## Prints all services that can handle the given INTENT
```
adb shell pm query-services INTENT
```

## Prints all broadcast receivers that can handle the given INTENT
```
adb shell pm query-receivers INTENT
```

## Install package with default options for user 0
```
adb shell pm install --user 0 PATH_TO_APK
```

## Install package with default options for all users
```
adb shell pm install PATH_TO_APK
```

## Install package with default options for the current user
```
adb shell pm install PATH_TO_APK
```

## Install package with the option to retain data and cache for user 0
```
adb shell pm install -r --user 0 PATH_TO_APK
```

## Install package with the option to retain data and cache for all users
```
adb shell pm install -r PATH_TO_APK
```

## Install package with the option to retain data and cache for the current user
```
adb shell pm install -r PATH_TO_APK
```

## Install package with the option to retain only the cache for user 0
```
adb shell pm install -r --user 0 PATH_TO_APK
```

## Install package with the option to retain only the cache for all users
```
adb shell pm install -r PATH_TO_APK
```

## Install package with the option to retain only the cache for the current user
```
adb shell pm install -r PATH_TO_APK
```

## Install package with the option to grant all runtime permissions and retain data and cache for user 0
```
adb shell pm install -r -g --user 0 PATH_TO_APK
```

## Install package with the option to grant all runtime permissions and retain data and cache for all users
```
adb shell pm install -r -g PATH_TO_APK
```

## Install package with the option to grant all runtime permissions and retain data and cache for the current user
```
adb shell pm install -r -g PATH_TO_APK
```

## Uninstall Package
```
adb shell pm uninstall PACKAGE
```

## Clear Package Data
```
adb shell pm clear PACKAGE
```

## Enable Package or Component
```
adb shell pm enable PACKAGE_OR_COMPONENT
```

## Disable Package or Component
```
adb shell pm disable PACKAGE_OR_COMPONENT
```

## Hide Package or Component
```
adb shell pm hide PACKAGE
```

## Unhide Package or Component
```
adb shell pm unhide PACKAGE
```

## Grant Permission
```
adb shell pm grant PACKAGE PERMISSION
```

## Revoke Permission
```
adb shell pm revoke PACKAGE PERMISSION
```

## Reset Permissions
```
adb shell pm reset-permissions PACKAGE
```

## Create User
```
adb shell pm create-user USER_NAME
```

## Remove User
```
adb shell pm remove-user USER_ID
```

## Set User Restriction
```
adb shell pm set-user-restriction RESTRICTION STATE USER_ID
```

## Get Maximum Users
```
adb shell pm get-max-users
```

## Get Maximum Running Users
```
adb shell pm get-max-running-users
```
