# Helpi backend

NestJS API backed by PostgreSQL and Prisma. The API connects people seeking financial support with helpers and NGOs. A request contains a support group and an amount; the app does not ask for the reason or track how assistance is paid.

## Database setup

The schema is PostgreSQL and its SQL is versioned under `prisma/migrations`. The migration lock file belongs at `prisma/migrations/migration_lock.toml`; keep schema changes in timestamped migration folders rather than applying untracked SQL to a live database.

### Use Supabase Postgres

1. In Supabase, open **Connect** and copy the **Session pooler** connection string on port `5432` (or the direct connection if your network supports IPv6). Prisma migrations need a direct/session connection, not the transaction pooler on port `6543`.
2. Copy `.env.example` to `.env` in this directory and set `DATABASE_URL` to that connection string. URL-encode special characters in the database password. Do not commit `.env` or share the connection string.
3. Install backend dependencies with `npm install`.
4. Apply all pending SQL migrations and generate the Prisma client: `npm run db:setup` (`npm.cmd run db:setup` in Windows PowerShell if script execution is restricted).
5. Check migration state with `npm run db:status`, then start the API with `npm run start:dev` and check `http://localhost:3000/api/health`.

`db:setup` runs `prisma validate`, `prisma generate`, and `prisma migrate deploy` in order. It does not reset or drop existing data. For a new empty Supabase project it creates the Helpi tables from the checked-in SQL migrations. The application API uses the server-side database connection; do not put the database password or service credentials in either frontend.

### Use local PostgreSQL

For local development, copy `.env.example` to `.env`, keep its local `DATABASE_URL`, start Docker Desktop, and run `docker compose up -d postgres`. Then run `npm install` and `npm run db:setup` before starting the API. Docker Desktop is not installed in the current workspace, so the local `localhost:5432` database cannot be started here; use your Supabase connection or install/start PostgreSQL locally.

The NestJS entry point loads `.env` automatically. Development CORS allows loopback origins on any port; production must use explicit `CORS_ORIGINS` values. Set unique secrets before production and set `EXPOSE_DEV_TOKENS=false`.

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
