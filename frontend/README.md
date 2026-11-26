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

## Deploying the user web portal

The Flutter app can run as a web portal as well as a mobile app. Build it as a separate static site and publish the `frontend/build/web` directory with an SPA fallback to `/index.html`.

Build with production URLs configured:

    flutter build web --release --base-href / --dart-define=API_URL=https://api.example.com/api --dart-define=ADMIN_PORTAL_URL=https://admin.example.com

Replace the example API and admin URLs with the production URLs. Add both deployed portal origins to the backend `CORS_ORIGINS` setting. Set `NEXT_PUBLIC_USER_PORTAL_URL` in the Vercel admin project to the published Flutter site URL, then redeploy the admin site. The admin page links to the user portal when that setting is present; the Flutter sign-in page links back to admin when `ADMIN_PORTAL_URL` is supplied at build time.
