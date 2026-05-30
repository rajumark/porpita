# Advanced Android Telecom Commands

## Dump default dialer
```
adb shell telecom get-system-dialer
adb shell telecom get-default-dialer
```

## Dump simcards slots
```
adb shell telecom get-max-phones
```

## Enable a Phone Account
```
adb shell telecom set-phone-account-enabled com.example.telecom 1234567890 user123
```

## Disable a Phone Account
```
adb shell telecom set-phone-account-disabled com.example.telecom 1234567890 user123
```

## Register a Phone Account with a Label
```
adb shell telecom register-phone-account com.example.telecom 1234567890 user123 "Work"
```

## Register a SIM Phone Account with Optional Capabilities
```
adb shell telecom register-sim-phone-account -e com.example.telecom 1234567890 user123 "Personal"
```

## Set a User-Selected Outgoing Phone Account with Optional Capabilities
```
adb shell telecom set-user-selected-outgoing-phone-account -e com.example.telecom 1234567890 user123
```

## Set a Test Call Redirection App
```
adb shell telecom set-test-call-redirection-app com.example.callredirection
```

## Set a Test Call Screening App
```
adb shell telecom set-test-call-screening-app com.example.callscreening
```

## Set a Phone Account Suggestion Component
```
adb shell telecom set-phone-acct-suggestion-component com.example.suggestion
```

## Add or Remove a Call Companion App
```
adb shell telecom add-or-remove-call-companion-app com.example.companion 1
```

## Register a SIM Phone Account with an Address
```
adb shell telecom register-sim-phone-account com.example.telecom 1234567890 user123 "Home" "123 Main St"
```

## Unregister a Phone Account
```
adb shell telecom unregister-phone-account com.example.telecom 1234567890 user123
```

## Set a Call Diagnostic Service
```
adb shell telecom set-call-diagnostic-service com.example.diagnostic
```

## Set a Default Dialer
```
adb shell telecom set-default-dialer com.example.dialer
```

## Get the Default Dialer
```
adb shell telecom get-default-dialer
```

## Get the System Dialer
```
adb shell telecom get-system-dialer
```

## Wait for Handlers to Finish
```
adb shell telecom wait-on-handlers
```

## Set the SIM Count
```
adb shell telecom set-sim-count 2
```

## Get the SIM Configuration
```
adb shell telecom get-sim-config
```

## Get the Maximum Number of Phones
```
adb shell telecom get-max-phones
```

## Stop Suppressing the Blocked Number Provider after a Call to Emergency Services
```
adb shell telecom stop-block-suppression
```

## Clear Any Disconnected Calls that have Gotten Wedged in Telecom
```
adb shell telecom cleanup-stuck-calls
```

## Remove Any Orphaned Phone Accounts that No Longer have a Valid UserHandle or Belong to an Installed Package
```
adb shell telecom cleanup-orphan-phone-accounts
```
