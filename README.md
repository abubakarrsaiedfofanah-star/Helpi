# Helpi — Real Humanitarian Assistance App

Helpi is one community-support platform with two role-based portals and one shared backend/database:

- **Community portal:** the React Native/Expo user app for people seeking help and helpers. It runs on Android and as an installable PWA.
- **Admin portal:** the Next.js operations website, also installable as a PWA.
- **Shared backend:** NestJS API with PostgreSQL managed through Prisma migrations. All portals use the same accounts and API; administrators sign in with an account granted the `ADMIN` role.

## Included now
- Real PostgreSQL persistence with Prisma
- Secure registration/email verification flow
- Argon2id password hashing
- Short-lived access JWTs + rotating refresh sessions
- MFA/TOTP with encrypted secret storage
- Session/device controls and security audit logs
- Global rate limiting, validation, Helmet/HSTS, CORS allowlist and request IDs
- Verified-case publication workflow
- Human verification queue with reviewer decisions and audit trail
- Fraud signal engine with duplicate/thin-description/high-value signals and review workflow
- Signed payment-provider webhook verification
- Payment intent + transaction ledger foundation
- Authenticated Socket.IO realtime messaging
- Reports, referrals, notifications and help offers
- Admin/verification dashboard statistics
- Expo app with secure native token storage, account access, case discovery, support requests, conversations, notifications and a responsive PWA

## Run backend
1. Copy `backend/.env.example` to `backend/.env` and set strong secrets plus a reachable PostgreSQL `DATABASE_URL` (local Postgres or Supabase session/direct connection).
2. From `backend`, run `npm install` and `npm run db:setup` to validate the Prisma schema, generate the client, and apply the checked-in SQL migrations.
3. Run `npm run start:dev`.
4. API: `http://localhost:3000/api` and Swagger: `http://localhost:3000/api/docs`.

For Supabase setup and connection details, see [`backend/README.md`](backend/README.md). Database passwords belong only in `backend/.env` and Vercel/backend server environment settings, never in Flutter or Next.js public variables.

The admin website and Expo user PWA ship together in the existing Vercel project: admin is `/`, community app is `/community/`. Android APKs are built separately with Expo EAS. The Expo web build uses the same configured API URL. See [`user-app/README.md`](user-app/README.md) and [`admin/README.md`](admin/README.md). The earlier Flutter client remains in `frontend/` as a migration reference.

## Run the Expo community app
1. Install Node.js and npm.
2. From `user-app`, run `npm ci` and `npx expo start`.
3. Configure `EXPO_PUBLIC_API_URL` to your reachable API URL for production builds. Android emulators use `http://10.0.2.2:3000/api` for local development.
4. Build an installable APK with `npx eas-cli build --platform android --profile production` after Expo EAS login.

## Production payment rule
The payment endpoint creates an intent and ledger record. Actual money movement must be performed and confirmed by a configured regulated payment provider. The signed webhook is the source of provider confirmation. Never store raw card data in Helpi.

## Verification rule
New cases enter `UNDER_REVIEW` + `PENDING`. A case becomes publicly discoverable only when a verifier/admin records `VERIFIED`, which changes the case to `PUBLISHED`.

## Security rule
AI/fraud signals are investigation signals, not guilt findings. Important account, verification, safeguarding and payment decisions require authorized human review.

## Production infrastructure layer added
- Private S3-compatible object storage with signed URLs and KMS encryption.
- Evidence registration and secure download authorization.
- OCR provider adapter with manual-review fallback.
- KYC provider adapter and identity verification schema.
- Sanctions screening adapter with review-required fallback.
- Fraud graph node/edge storage and risk signal analysis.
- Push notification adapter.
- Voice/video room service boundary with provider configuration.
- Safeguarding case workflow and priority queue.
- Country-aware payment adapter routing with a Kenya M-Pesa Daraja adapter.
- Payment attempts and exchange-rate snapshots.
- Next.js Trust & Safety administrative dashboard.

Integrations that require commercial/provider credentials deliberately fail closed or return a configuration-required/manual-review state rather than pretending a verification, payment, OCR result, notification, or live call actually happened.


## v6 product improvements
- Richer responsive mobile home experience with impact, emergency and notifications shortcuts.
- Progress-aware case cards and category discovery.
- Personal impact dashboard and notification center.
- Expanded profile safety messaging.
- Expanded administrative operations console navigation and safeguards.
- Added authenticated `/api/impact/me` endpoint.

## V9 privacy-first media and anonymous public identity

Helpi now supports short video evidence on help requests and privacy-preserving public identities. Video is private until human safety review approves it for public playback. Users can publish under their real name, an alias, or an anonymous public identity while Helpi retains only the identity information required for security, verification, payments, safeguarding and compliance.

See `VIDEO_PRIVACY.md` for the security and privacy rules.
