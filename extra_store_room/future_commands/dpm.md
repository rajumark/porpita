# Device Policy Management on Android with ADB

## Prints the help text
```
adb shell dpm help
```

## Checks if the given operation is safe
```
adb shell dpm is-operation-safe <OPERATION_ID>
```

## Checks if the operations are safe for the given reason
```
adb shell dpm is-operation-safe-by-reason <REASON_ID>
```

## Emulates the result of the next call to check if the given operation is safe
```
adb shell dpm set-operation-safe <OPERATION_ID> <REASON_ID>
```

## Lists the device / profile owners per user
```
adb shell dpm list-owners
```

## Lists the apps that are exempt from policies
```
adb shell dpm list-policy-exempt-apps
```

## Sets the given component as active admin for an existing user
```
adb shell dpm set-active-admin [ --user <USER_ID> | current ] <COMPONENT>
```

## Sets the given component as active admin, and its package as device owner
```
adb shell dpm set-device-owner [ --user <USER_ID> | current *EXPERIMENTAL* ] [ --device-owner-only ] <COMPONENT>
```

## Sets the given component as active admin and profile owner for an existing user
```
adb shell dpm set-profile-owner [ --user <USER_ID> | current ] <COMPONENT>
```

## Disables an active admin, the admin must have declared android:testOnly in the application in its manifest
```
adb shell dpm remove-active-admin [ --user <USER_ID> | current ] <COMPONENT>
```

## Clears framework-maintained record of past freeze periods that the device went through
```
adb shell dpm clear-freeze-period-record
```

## Makes all network logs available to the DPC and triggers DeviceAdminReceiver.onNetworkLogsAvailable()
```
adb shell dpm force-network-logs
```

## Makes all security logs available to the DPC and triggers DeviceAdminReceiver.onSecurityLogsAvailable() if needed
```
adb shell dpm force-security-logs
```

## Marks the profile owner of the given user as managing an organization-owned device
```
adb shell dpm mark-profile-owner-on-organization-owned-device [ --user <USER_ID> | current ] <COMPONENT>
```
