# Helpi Threat Model

## Assets
- Identity and contact information
- Verification evidence and sensitive documents
- Help-case narratives and location information
- Payment and transaction records
- Authentication secrets and sessions
- Messages and safeguarding reports

## Primary threats
1. Account takeover
2. Credential stuffing and brute force
3. Fake/duplicate help cases
4. Stolen or manipulated evidence
5. Payment fraud and webhook spoofing
6. Unauthorized access to vulnerable-person information
7. Harassment/scams through messaging
8. Insider misuse of verification/admin privileges
9. Data leakage from logs/backups
10. API abuse and denial of service

## Current controls
- Argon2id password hashing
- Email verification before account activation
- MFA/TOTP
- Short-lived access tokens
- Rotating refresh sessions
- Session revocation
- Rate limits and login throttling
- Strict validation/unknown-field rejection
- CORS allowlist
- Helmet/HSTS
- Request IDs and audit logs
- Role-based verification/admin controls
- Verified-before-public case publication
- Signed payment webhooks
- Transaction ledger
- Authenticated realtime messaging
- Human review for verification/fraud decisions

## Required before production launch
- Managed secrets/KMS
- Object storage with private buckets and signed URLs
- Malware/document scanning
- OCR and evidence integrity checks
- Device/risk telemetry with privacy controls
- Full fraud graph and duplicate-image/document detection
- Regulated payment provider integrations per country
- KYC/KYB/AML/sanctions screening where legally required
- WAF/DDoS protection
- Centralized monitoring/SIEM and alerting
- Immutable audit-log retention
- Independent penetration test and threat-model review
- Backup restore drills and disaster-recovery testing
- Safeguarding review and child-safety controls
