# Helpi v12 — Payment Guardian & Anti-Fraud

## Applied controls
- Backend-authoritative payment status; the Flutter client cannot mark a payment successful.
- Fail-closed payment intents: an enabled country/currency payment provider must exist before an intent is created.
- Payment idempotency keys prevent replay/duplicate intent creation when supplied.
- Provider webhook signatures are verified with HMAC and timing-safe comparison.
- Provider events require transaction ID, provider reference and event type.
- Duplicate provider events are idempotent through `PaymentWebhookEvent`.
- Provider amount and currency are checked against the original transaction.
- Payment state transitions are enforced (`CREATED -> PROCESSING -> SUCCEEDED/FAILED`, `SUCCEEDED -> REFUNDED`).
- Invalid transitions and provider mismatches are rejected and the transaction is marked failed with a reason.
- Financial actions are audit logged.
- Client receipt/screenshots are not accepted as proof of payment.
- Payment listing exposes status and block reason without exposing internal provider secrets.

## Production requirements
Real provider adapters must be configured with regulated provider credentials and authoritative webhook verification. Do not enable a provider record until its credentials, callback endpoint, signature scheme, settlement account, reconciliation process and legal/compliance requirements have been verified.

Dependency installation could not be completed in the current build environment because `npm install` timed out. The source changes are packaged, but Prisma generation/build has not been claimed as successful.

## V12.1 Account takeover and payout protection
- New-device sign-ins create security events and user notifications.
- Refresh sessions can be revoked together after suspected compromise.
- Payout destinations are stored by hash, expose only the last four characters, and are never treated as verified merely because they were submitted.
- A recent burst of new-device activity places a payout destination into review rather than allowing immediate use.
- Payout destination records support approval history for two-person review workflows.
- Security-sensitive actions remain server-authoritative and auditable.
