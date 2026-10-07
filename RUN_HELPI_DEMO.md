# Enter Helpi Now — Local App Preview

The project now has a safe **local preview mode** so you can enter the app and inspect the mobile UI immediately without a backend, real account, or real payment.

### Android Studio
1. Extract this ZIP.
2. Open the `frontend` folder in Android Studio.
3. Make sure Flutter/Dart support is installed.
4. Select an Android emulator or your Android phone.
5. Run with this Dart define:
   `HELPI_DEMO=true`
6. Start the app.
7. On the Helpi login screen, tap **ENTER APP PREVIEW**.

### Windows shortcut
Double-click `RUN_HELPI_DEMO.bat` from the project root after Flutter is installed and available in PATH.

### What preview mode does
- Opens the real Flutter UI.
- Lets you move through the main navigation.
- Shows sample verified cases on Home and Explore.
- Does not create real accounts.
- Does not create real payments.
- Does not contact payment providers.
- Does not bypass production authentication when the demo define is omitted.

For a real production run, remove `HELPI_DEMO=true` and configure the backend/payment providers normally.
