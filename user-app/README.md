# Helpi user app (Expo)

The community app is being moved to React Native with Expo. This app uses the existing Helpi API and database; it does not create a second backend or database.

## Run locally

Install Node.js, then run:

```sh
npm ci
npx expo start
```

For a local API, Android emulators use `http://10.0.2.2:3000/api`; web and other local development use `http://localhost:3000/api`.

## Production API

Set `EXPO_PUBLIC_API_URL` to the deployed HTTPS API base before making a production Android build or web export. The API URL is compiled into the app bundle. A production build intentionally does not fall back to a localhost or emulator address.

For Vercel, set `NEXT_PUBLIC_API_URL` in the existing admin project. The shared build forwards it into this app's Expo web export, which is copied to `/community/`.

## Android APK

The EAS `preview` and `production` profiles are configured to produce installable APKs. To build one, authenticate with Expo EAS and run:

```sh
npx eas-cli build --platform android --profile production
```

The first Android app identifier is retained as `com.example.helpi` to match the earlier Flutter build. Android only accepts an in-place update when the signing certificate also matches; a different signer requires uninstalling the previous APK first.

## Transition

The original Flutter source remains in `../frontend` for reference during the migration. The shared Vercel build uses this Expo app for the community PWA.
