# Helpi legacy Flutter client

The current user app migration is in `../user-app` and uses React Native with Expo. This Flutter folder is kept temporarily as a reference during the transition.

## Legacy Android build

To build the old Flutter APK, configure a backend address reachable by the phone:

```sh
flutter build apk --release --dart-define=API_URL=https://api.example.com/api
```

The APK is written to `build/app/outputs/flutter-apk/app-release.apk`. The emulator default (`10.0.2.2`) only works from an emulator; a physical phone needs a public HTTPS API URL or a reachable computer LAN address. This legacy build uses the debug signing key and is not suitable for Play Store publishing.

The legacy Flutter web build is no longer used by Vercel. The current single-project PWA and Expo Android setup are documented in [`../user-app/README.md`](../user-app/README.md).
