# Helpi Admin Portal

Next.js portal for community operations. It is organized around the work Helpi supports: requests by group and amount, people and account access, NGO/community partners, safety reports and administrator audit history.

The admin portal is installable as a PWA on supported browsers. Open the deployed admin URL in the browser and choose **Install app** or **Add to Home Screen**. The service worker only caches versioned static assets and icons; it does not cache admin pages, session data, or API responses.

## Run locally

1. Start the API and database using `backend/README.md`.
2. Set `NEXT_PUBLIC_API_URL` to the API origin and `/api` prefix (for example `http://localhost:3000/api`).
3. Install packages with `npm install` and run `npm run dev`.
4. Sign in with an active, email-verified account that has the `ADMIN` role. Enter an authenticator code when MFA is enabled.

For Vercel, the repository-root `vercel.json` routes the NestJS API under `/api` and serves this Next.js admin portal at `/`, with the Flutter community PWA at `/community/`. Use one Vercel project with the repository root as its root directory and **Services** as its framework preset. Set `NEXT_PUBLIC_API_URL` to the Vercel production domain plus `/api` and `NEXT_PUBLIC_ADMIN_PORTAL_URL` to that domain.

The access token is kept in the browser's session storage and cleared when the admin signs out or the session ends. Serve the portal and API over HTTPS outside local development, and restrict CORS to the portal origin.

## Portal workspaces

- **Dashboard:** current account and request counts, open reports, organizations and request groups.
- **Requests:** published support requests, filtered by category and searchable by group/location/public label.
- **People:** searchable accounts with status and group; admins can suspend or reactivate accounts. Pending accounts cannot be activated from this workspace.
- **Organizations:** registered NGOs and community partners.
- **Safety reports:** open and in-review reports; resolution and dismissal actions are audit logged.
- **Audit trail:** recent admin changes and their metadata.

The portal does not review financial need, ask for a request reason, verify payment, or track transfers.
