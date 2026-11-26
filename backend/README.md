# Helpi backend

NestJS API backed by PostgreSQL and Prisma. The API connects people seeking financial support with helpers and NGOs. A request contains a support group and an amount; the app does not ask for the reason or track how assistance is paid.

## Database setup

The schema is PostgreSQL and its SQL is versioned under `prisma/migrations`. The migration lock file belongs at `prisma/migrations/migration_lock.toml`; keep schema changes in timestamped migration folders rather than applying untracked SQL to a live database.

### Use Supabase Postgres

1. In Supabase, open **Connect** and copy the **Session pooler** connection string on port `5432` (or the direct connection if your network supports IPv6). Prisma migrations need a direct/session connection, not the transaction pooler on port `6543`.
2. Copy `.env.example` to `.env` in this directory and set `DATABASE_URL` to that connection string. URL-encode special characters in the database password. Do not commit `.env` or share the connection string.
3. Install backend dependencies with `npm install`.
4. Apply all pending SQL migrations, generate the Prisma client, and seed country operations: `npm run db:setup` (`npm.cmd run db:setup` in Windows PowerShell if script execution is restricted).
5. Check migration state with `npm run db:status`, then start the API with `npm run start:dev` and check `http://localhost:3000/api/health`.

`db:setup` runs `prisma validate`, `prisma generate`, `prisma migrate deploy`, and the idempotent country-configuration seed. It does not reset or drop existing data. The checked-in migrations also enable row-level security with no public client policies; the NestJS API must connect with the private Supabase PostgreSQL owner role so it can access tables and apply authorization in the API. Do not put the database password or service credentials in either frontend.

### Setup in the Supabase SQL Editor

If you want to create a brand-new Supabase database by pasting SQL:

1. In a fresh Supabase project, open **SQL Editor** and run [`supabase/parts/helpi_schema_part_1.sql`](supabase/parts/helpi_schema_part_1.sql), then `part_2.sql`, then `part_3.sql`, as three separate queries in that order. The smaller files avoid query truncation in the SQL Editor. The combined file [`supabase/helpi_complete_schema.sql`](supabase/helpi_complete_schema.sql) is for tools that execute SQL files directly. This setup creates the current Prisma schema, seeds country settings, and enables row-level security. It does not create a demo/admin account.
2. Copy the Supabase Session Pooler or Direct connection URI (port `5432`) into `DATABASE_URL` in `backend/.env`.
3. From `backend`, run `npm install`, then `npm run db:baseline:supabase`. This records the checked-in Prisma migration history for the schema you just created; it does not run or reset the SQL a second time.
4. Run `npm run db:status` and `npm run db:setup`. The setup command should report the migrations as applied, regenerate Prisma, and safely seed country configuration.

Generate updated SQL exports after schema changes with `npm run db:export:supabase`. Use normal Prisma migrations for future changes. **Do not run the bootstrap over a database that already has Helpi tables or data.** For an existing project, set `DATABASE_URL` and run `npm run db:setup` instead.

RLS has no policies for Supabase `anon` or `authenticated` roles, so browser/mobile code must not query these tables with a Supabase public key. All access goes through the NestJS API using its private database connection.

### Deploy the API in the same Vercel project

The repository-root `vercel.json` uses Vercel Services to route `/api/*` to this NestJS service while the same deployment serves the admin and Flutter web app. In the existing Vercel project, set the Root Directory to the repository root and Framework Preset to **Services**. Add `DATABASE_URL`, `JWT_ACCESS_SECRET`, `MFA_ENCRYPTION_KEY_B64`, and `CORS_ORIGINS=https://helpi-eight.vercel.app` as server environment variables. Use the Supabase Session Pooler URI for `DATABASE_URL`; never prefix it with `NEXT_PUBLIC_`. Also configure the email webhook variables before enabling account registration. The API then shares the Vercel domain at `https://helpi-eight.vercel.app/api`; the frontend's `NEXT_PUBLIC_API_URL` should use that URL. If the SQL Editor bootstrap was used, run `npm run db:baseline:supabase` once before relying on future Prisma migrations.

### Use local PostgreSQL

For local development, copy `.env.example` to `.env`, keep its local `DATABASE_URL`, start Docker Desktop, and run `docker compose up -d postgres`. Then run `npm install` and `npm run db:setup` before starting the API. Docker Desktop is not installed in the current workspace, so the local `localhost:5432` database cannot be started here; use your Supabase connection or install/start PostgreSQL locally.

The NestJS entry point loads `.env` automatically. Development CORS allows loopback origins on any port; production must use explicit `CORS_ORIGINS` values. Set unique secrets before production and keep `EXPOSE_DEV_TOKENS=false`.

For production sign-ups, configure `EMAIL_WEBHOOK_URL`, `EMAIL_WEBHOOK_SECRET`, and `EMAIL_VERIFICATION_BASE_URL` in the API environment. The API sends a `POST` with `Authorization: Bearer <EMAIL_WEBHOOK_SECRET>` and a JSON `event: "email.verification"` payload containing `to`, `subject`, `text`, `verificationUrl`, and a single-use `verificationToken` that expires in 30 minutes. The webhook must deliver the email and return a `2xx` response. The verification link should open the `/community/` Flutter web app; the app completes verification and then lets the user sign in. Without email delivery configured, registration fails clearly instead of creating an account that cannot be activated. Local development may set `EXPOSE_DEV_TOKENS=true` to verify accounts without the mail webhook; never do this in production.

## Connecting the Flutter app

- Android emulator: the default API URL is `http://10.0.2.2:3000/api`.
- Flutter web and desktop: the default API URL is `http://localhost:3000/api`.
- Physical phone: run with `flutter run --dart-define=API_URL=http://YOUR_COMPUTER_LAN_IP:3000/api` while both devices are on the same network. Allow port 3000 through the computer's firewall if needed.
- Start the admin Next.js app on port 3001 with `npm run dev -- -p 3001`; it uses the API at port 3000 by default.

The API listens on `0.0.0.0` so a phone on the local network can reach it. A local database is still required; the API cannot start successfully until Postgres is running and migrations are applied.

The API uses `/api` as its global prefix and publishes an OpenAPI document at `/api/docs` while the server is running.

## Core API areas

- `POST /api/auth/register`, `POST /api/auth/login`, email verification and account MFA.
- `GET /api/cases`, `GET /api/cases/:id`, `GET /api/cases/mine`, `POST /api/cases` and request status updates.
- `GET /api/messages/threads`, thread creation and direct messages between the helper and the request's account owner. When somebody posts for a person without an account, the poster's account is the contact point.
- `POST /api/reports` for community conduct and safeguarding reports.
- `GET /api/country-operations/public/:code` for public language and currency settings.
- Admin-only routes under `/api/admin` for community counts, published requests, accounts, organizations, open safety reports and audit activity.

## Admin API

Every `/api/admin` route requires an active, email-verified account with the `ADMIN` role. The portal uses the same MFA-aware sign-in as the app.

| Method and path | Purpose |
| --- | --- |
| `GET /admin/dashboard` | Counts for accounts, requests, reports, organizations and request groups |
| `GET /admin/users?q=&status=&page=&pageSize=` | Search accounts with bounded pagination |
| `PATCH /admin/users/:id/status` | Activate, suspend or disable an account; protects the last active administrator |
| `GET /admin/requests` | Published request group, amount, public name and location |
| `GET /admin/organizations` | NGO and community organization directory |
| `GET /admin/safety-reports` | Open and in-review community reports |
| `PATCH /admin/safety-reports/:id/status` | Mark a report in review, resolved or dismissed |
| `GET /admin/audit` | Recent administrator action history |

Account and report status changes are written to the audit log in the same database transaction. Admin request views do not include financial verification queues or payment activity.

## Configuration notes

- Set `CORS_ORIGINS` to the exact trusted frontend and admin origins.
- Use HTTPS, long random secrets, private database backups and a managed secrets store outside local development.
- Configure email delivery for account verification and recovery.
- Add distributed rate limiting before running multiple API instances.
- Use database migrations for schema changes; do not use `db push` in production.
