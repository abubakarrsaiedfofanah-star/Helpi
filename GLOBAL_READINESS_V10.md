# Helpi Global Readiness v10

## Product principles
- Global reach with country-specific rules.
- Public anonymity is separate from private platform identity.
- Original transaction currency remains authoritative.
- Exact vulnerable-person addresses are never public.
- Verification and fraud signals are reviewed by people for consequential decisions.
- Low-connectivity users get drafts, retry behavior and reduced media usage.
- Accessibility is a first-class product requirement.

## New Global Center
The mobile app now exposes a Global Center for:
- language and translation
- currency and payment context
- accessibility
- low-data mode
- emergency resources
- privacy and anonymous public identity
- offline drafts
- safety and safeguarding

## Admin Global Operations
The web dashboard now includes a Global Operations workspace covering:
- country/currency registry
- language coverage
- accessibility readiness
- low-data/offline readiness
- payment routing
- local verification/safeguarding requirements
- emergency-resource directory
- regional operating policies

## API
`GET /api/global/capabilities` returns the platform capability contract for clients and operations tooling.

## Production requirements
Before launch, populate country-specific legal, payment, KYC/KYB, sanctions, emergency-resource and safeguarding configuration from authoritative providers and qualified local/legal review. Do not infer legal requirements from the UI.


## Country Operations V11
Country behavior is now data-driven through `CountryConfiguration`. Each country can independently configure languages, currencies, payment methods, KYC/KYB requirements, safeguarding rules, emergency resources, accepted document types, retention rules, help methods, verification rules and communication rules.

- Public client config: `GET /api/country-operations/public/:code`
- Admin registry: `GET /api/country-operations`
- Admin country detail: `GET /api/country-operations/:code`
- Admin update: `PATCH /api/country-operations/:code`
- Seed baseline: `npm run country:seed`
- Case creation now checks that the selected country is enabled and that its currency is enabled.

Configuration changes are audited through `COUNTRY_CONFIGURATION_UPDATED`. The JSON country registry remains the baseline identity/currency catalogue; operational policy is stored in PostgreSQL so countries can be changed without rebuilding the application.
