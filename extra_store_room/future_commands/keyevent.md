# keytool | Cheatsheet

adb shell keytool is a command-line utility for managing cryptographic keys and certificates on an Android device.
It provides functions for generating, importing, exporting, and managing key pairs, certificates, and keystores. This tool is commonly used for tasks related to securing and authenticating Android apps

## Generate hash from keystore (Typically used in Facebook)
```
keytool -exportcert -alias your_alias -keystore debug.keystore \
| openssl sha1 -binary \
| openssl base64
```

## Typically used in Google Maps
```
keytool -list -v -keystore ~/.android/debug.keystore -alias your_alias
```
