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

The Android app remains a Flutter app. The same Flutter project is also built as an installable PWA at `/community/` inside the same Vercel project as the public download landing page and admin portal. The public download page is `/`, the community app is `/community/`, and the admin portal is `/admin`.

The web app uses `/community/` as its base path inside the shared Vercel project. To build it manually with production URLs configured:

    flutter build web --release --base-href /community/ --dart-define=API_URL=https://helpi-eight.vercel.app/api

The single Vercel project uses Vercel Services, defined in the repository-root `vercel.json`, to serve the public download landing page, admin website, Flutter PWA, and NestJS API together. Set the Vercel project root directory to the repository root and its framework preset to **Services**. Set `NEXT_PUBLIC_API_URL` to `https://helpi-eight.vercel.app/api` (or your current Vercel domain plus `/api`). The Flutter SDK is downloaded automatically during the build. Set backend `CORS_ORIGINS` to the Vercel site origin.

On a supported mobile browser, users can install Helpi from the browser's install or add-to-home-screen option. The service worker caches the app shell and static app files so the PWA can open after a successful first load without a connection. Account, request, and other server-backed features still need the API connection; API responses are deliberately not cached. The Android build remains available independently of the web PWA.
