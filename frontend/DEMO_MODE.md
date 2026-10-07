# Helpi App Preview Mode

This is a local UI exploration mode. It never creates real payments, real donations, or real accounts.

## Android Studio
1. Open the `frontend` folder as the Flutter project.
2. Choose an emulator or connected Android device.
3. In **Run > Edit Configurations**, add a Dart define:
   `HELPI_DEMO=true`
4. Run the app.
5. Tap **ENTER APP PREVIEW** on the login screen.

## Command line
```bash
flutter pub get
flutter run --dart-define=HELPI_DEMO=true
```

The preview supplies sample verified cases so Home and Explore can be opened without a backend. Production builds should omit the define.
