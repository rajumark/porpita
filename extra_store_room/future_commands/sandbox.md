# SDK Sandbox (sdk_sandbox) Commands

## Start the SDK Sandbox for an App
To initiate the SDK sandbox for a specific application, use the start command. This command is especially useful for developers looking to test their applications in a sandboxed environment.

```
adb shell cmd sdk_sandbox start --user 0 com.example.myapp
```

This command starts the sandbox for com.example.myapp for the primary user (user ID 0). If you don't specify a user, it defaults to the current user.

## Stop the SDK Sandbox for an App
When testing is complete, or if you need to halt the sandboxed execution of an app, use the stop command. This ensures that the app no longer runs within the SDK sandbox, reverting back to its standard operation mode.

```
adb shell cmd sdk_sandbox stop --user 0 com.example.myapp
```

This stops the SDK sandbox for com.example.myapp for the primary user. Similar to the start command, specifying a user is optional.

## Set the SDK Sandbox State
Managing the state of the SDK sandbox is crucial for testing different scenarios. The set-state command allows you to enable the sandbox or reset its state, ensuring that the sandbox environment is prepared according to your testing requirements.

### Enable the Sandbox State
```
adb shell cmd sdk_sandbox set-state --enabled
```

This command enables the SDK sandbox state, preparing it for subsequent app testing.

### Reset the Sandbox State
```
adb shell cmd sdk_sandbox set-state --reset
```

Resetting the state is useful when you want to clear any previous configurations or settings, ensuring that the next SDK load starts with a clean slate.
