# Shortcut

## Reset throttling for all packages and users
```
adb shell cmd shortcut reset-throttling --user 0
```

## Reset the throttling state for all users
```
adb shell cmd shortcut reset-all-throttling
```

## Override the configuration for testing (will last until reboot)
```
adb shell cmd shortcut override-config CONFIG
```

## Reset the configuration set with "update-config"
```
adb shell cmd shortcut reset-config
```

## [Deprecated] Show the default launcher
Note: This command is deprecated. Callers should query the default launcher from RoleManager instead.
```
adb shell cmd shortcut get-default-launcher --user 0
```

## Unload a user from the memory (This should not affect any observable behavior)
```
adb shell cmd shortcut unload-user --user 0
```

## Remove all shortcuts from a package, including pinned shortcuts
```
adb shell cmd shortcut clear-shortcuts --user 0 PACKAGE
```

## Show the shortcuts for a package that match the given flags
```
adb shell cmd shortcut get-shortcuts --user 0 [--flags FLAGS] PACKAGE
```

## Prints "true" if the package can access shortcuts, "false" otherwise
```
adb shell cmd shortcut has-shortcut-access --user 0 PACKAGE
```
