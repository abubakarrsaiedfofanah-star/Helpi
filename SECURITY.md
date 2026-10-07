# Helpi Security Blueprint

## Identity
- Argon2id password hashing
- short-lived access tokens
- rotating refresh sessions
- session revocation
- account lockout after repeated failures
- email verification before account activation
- optional MFA/TOTP
- MFA secrets encrypted with AES-256-GCM

## API
- global throttling
- stricter login/register throttling
- Helmet headers
- HSTS
- CORS allowlist
- strict DTO validation
- request IDs
- authenticated write operations
- owner checks for private case operations

## Trust and safety
- cases are not automatically verified
- public discovery requires `PUBLISHED + VERIFIED`
- verification requests are persisted
- reports are persisted for human review
- referrals require consent
- suspicious activity must be investigated by people; AI should provide signals, not guilt judgments

## Data protection
- never store raw card data in Helpi
- keep sensitive evidence in private object storage
- encrypt highly sensitive fields
- use signed URLs with short expiry
- separate operational data from verification evidence
- maintain retention/deletion policies
- minimize public location information

## Production before real money or vulnerable-person data
- regulated payment provider integration
- webhook signature verification
- KYC/KYB and sanctions screening where required
- country-specific legal/privacy review
- safeguarding policy and escalation process
- WAF/DDoS protection
- centralized secrets manager
- backups + tested disaster recovery
- SIEM/security monitoring
- dependency and container scanning
- penetration testing
- incident response exercises
- independent privacy/security review

## Additional production controls
- Vulnerable-person evidence is private by default and accessed through short-lived signed URLs.
- Object storage uses server-side KMS encryption when configured.
- KYC, sanctions and OCR results are provider-backed or explicitly routed to manual review; the platform does not fabricate decisions.
- Payment routing is country-aware and records provider attempts separately from the internal transaction ledger.
- Safeguarding reports create a dedicated workflow for triage and investigation.
- Fraud graph relationships are stored as hashed node identifiers where possible to reduce direct exposure of sensitive identifiers.
- The administrative dashboard is a separate surface and should be protected with SSO/passkeys, device policy, IP/risk controls and step-up authentication before deployment.
