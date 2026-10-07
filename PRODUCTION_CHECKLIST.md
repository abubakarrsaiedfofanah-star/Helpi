# Helpi production checklist

This release adds the application boundaries for the requested production layer. Provider credentials and legal/compliance configuration are intentionally externalized.

## Required before handling real funds or sensitive identity documents

- [ ] Configure PostgreSQL with encrypted backups and tested restore procedures.
- [ ] Configure private object storage, KMS keys, lifecycle rules and signed URLs.
- [ ] Configure an OCR/document provider and test document retention/deletion policies.
- [ ] Configure a KYC/KYB provider per supported jurisdiction.
- [ ] Configure a sanctions/PEP/adverse-media screening provider and escalation process.
- [ ] Complete country-specific payment onboarding, merchant accounts, webhook signing and reconciliation.
- [ ] Configure FX source and persist rate snapshots for displayed conversions.
- [ ] Configure push notification credentials and device-token lifecycle.
- [ ] Configure a compliant voice/video provider with safeguarding controls and consent rules.
- [ ] Complete child-safeguarding policy, escalation contacts and response SLAs.
- [ ] Protect the admin portal with SSO/passkeys, step-up authentication, device policy and audit logs.
- [ ] Run threat modeling, SAST/dependency scanning, DAST, API authorization tests, penetration testing and load testing.
- [ ] Complete legal review for payments, KYC/AML, data protection, cross-border transfers and fundraising requirements in each launch jurisdiction.

## Fail-closed behavior

Where a required provider is not configured, Helpi returns a configuration/manual-review state instead of presenting a fake verification, payment, OCR, sanctions result, notification or live-call success.
