# Helpi Website v8

The web experience now includes responsive workspaces for discovery, trust, impact, organizations, countries, help circles and security.

## Product features represented
- Verified-help discovery
- Trust Passport / explanation of verification checks
- Proof-of-impact timeline concept
- Organization network
- Country-aware humanitarian pages
- Help Circles
- Appeals and fair-review workflow
- Fraud graph / investigation workspace
- Safeguarding operations
- Security operations
- Responsive mobile/tablet/desktop layouts
- Reduced-motion support
- PWA manifest and installable web shell

## Backend capabilities added
- Public verified-case feed
- Public country summary
- Public impact snapshots
- Verified organization directory
- Help Circle database and membership model
- Organization and staff membership model
- Appeals model
- Project + milestone model
- Public impact snapshot model
- Admin counts for organizations, circles and appeals

External payment, KYC/KYB, sanctions, OCR, push, voice/video and storage providers remain adapter-based and must be configured with real provider credentials before production use.

## V9 privacy-first video + anonymous public identity
- Case creators can record/select a short video (up to 3 minutes in the mobile UI).
- Video uploads use private signed object-storage URLs and a 100 MB limit.
- Video evidence is never public on upload; it starts in privacy/safety review.
- Admins have a media-review queue and must explicitly approve media before public playback.
- Public case media uses short-lived signed download URLs only after the case is published/verified and the media is approved.
- Users can choose a public identity mode: real name, alias, or anonymous.
- Anonymous means anonymous to ordinary public viewers/helpers; Helpi still retains the minimum identity information required for security, verification, payments, safeguarding, and legal compliance.
- The app warns users not to expose passwords, payment credentials, exact home addresses, or unnecessary images of children in videos.
