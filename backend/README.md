# Helpi API — production-oriented backend

This backend uses PostgreSQL + Prisma. There is intentionally no fake in-memory data layer.

## First database setup

```bash
cp .env.example .env
# Put a real random JWT_ACCESS_SECRET and MFA_ENCRYPTION_KEY_B64 in .env
npm install
npx prisma generate
npx prisma migrate dev --name initial
npm run start:dev
```

For staging/production, commit the generated migration and use:

```bash
npx prisma migrate deploy
npm run build
npm run start:prod
```

## Required production controls

- PostgreSQL with encrypted disks/backups
- TLS at the load balancer/API edge
- Redis-backed distributed rate limiting if multiple API instances run
- real email provider/webhook for verification and account recovery
- real FX provider configured through `FX_PROVIDER_URL`
- real payment provider and webhook verification before accepting money
- object storage with private buckets and signed URLs for evidence
- centralized secrets manager
- monitoring, alerting and audit-log retention
- WAF/DDoS protection
- independent penetration testing before launch

## Production integrations now prepared
- Verification queue and reviewer endpoints
- Fraud signal scanning/review endpoints
- Payment intents and signed webhook endpoint
- PostgreSQL transaction ledger
- Socket.IO authenticated realtime messaging
- Admin/security dashboard endpoints

Payment movement is deliberately provider-backed: configure a regulated provider (for example a country-appropriate mobile-money/card/bank provider) before accepting real funds. Do not treat a created intent as a completed payment.
