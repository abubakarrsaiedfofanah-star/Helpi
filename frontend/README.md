# helpi

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Deploying the user app and PWA

### Android APK

Build a sideloadable release APK with the backend address reachable by the phone:

    flutter build apk --release --dart-define=API_URL=https://api.example.com/api

The APK is written to `build/app/outputs/flutter-apk/app-release.apk`. The Android emulator default (`10.0.2.2`) only works from an emulator; a physical phone needs the public HTTPS API URL or a reachable computer LAN address. This project currently signs release APKs with the debug key, which is suitable for direct installation but not Play Store publishing.

The Android app remains a Flutter app. The same Flutter project can also be built as an installable web app (PWA) and hosted as a separate static portal on Vercel. Keep the existing admin Vercel project rooted at `admin`; create a second Vercel project for the user portal rooted at `frontend` so the two portals can have separate domains.

Build the web app with production URLs configured:

    flutter build web --release --base-href / --dart-define=API_URL=https://api.example.com/api --dart-define=ADMIN_PORTAL_URL=https://admin.example.com

Deploy the resulting `build/web` directory from the linked user portal Vercel project (for example, with `vercel deploy build/web --prod`). Replace the example API and admin URLs with the real production URLs. Set `NEXT_PUBLIC_USER_PORTAL_URL` in the admin Vercel project's environment to the user portal URL, then redeploy the admin site. Add both portal origins to the backend `CORS_ORIGINS` setting.

On a supported mobile browser, users can install Helpi from the browser's install or add-to-home-screen option. The service worker caches the app shell and static app files so the PWA can open after a successful first load without a connection. Account, request, and other server-backed features still need the API connection; API responses are deliberately not cached. The Android build remains available independently of the web PWA.
