<<<<<<< HEAD
# QR
=======
# QR Tools (Flutter)

Android-first QR app with:
- QR generation (Text, URL, Phone, Email, WiFi)
- QR scanning (QR-only for MVP)
- Local history (Hive)
- Share/copy/save actions

## Local checks

```bash
flutter analyze
flutter test
```

## Android release signing (configured)

This project is already configured for release signing:
- Keystore: `android/keystore/upload-keystore.jks`
- Signing config: `android/key.properties`
- Gradle wiring: `android/app/build.gradle.kts`

Important:
- Keep `android/keystore/upload-keystore.jks` and `android/key.properties` safe backupda.
- `android/key.properties` va `android/keystore/` `.gitignore` ga qo'shilgan.

## Play Market build

Versionni `pubspec.yaml` da yangilang:
- `version: x.y.z+buildNumber`

So'ngra:

```bash
flutter build appbundle --release
```

Output:
- `build/app/outputs/bundle/release/app-release.aab`

Optional APK:

```bash
flutter build apk --release
```

Output:
- `build/app/outputs/flutter-apk/app-release.apk`

## Play Console upload

1. Google Play Console -> Create app.
2. `app-release.aab` ni upload qiling.
3. App content (Privacy Policy, Data safety, permissions) bo'limlarini to'ldiring.
4. Internal testing trackga yuborib test qiling.
5. Release rollout qiling.

## Eslatma

Agar release build `Could not GET ... dl.google.com` xatosi bersa,
bu internet/DNS/proxy muammosi. Tarmoq to'g'rilangandan keyin
`flutter build appbundle --release` ni qayta ishga tushiring.
>>>>>>> 213be65 (First commit)
