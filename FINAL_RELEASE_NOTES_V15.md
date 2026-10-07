# Helpi v15 — Final UX + Reliability Release

This release is the final polish layer on top of the v14 GUI/security build.

### Applied
- Consistent Material transitions, snackbar behavior, scroll treatment and accessibility focus.
- Mobile discovery now has explicit loading, offline/error and retry states.
- API calls use bounded timeouts and one retry for safe GET requests; low-level network failures are converted to safe user messages.
- Global Flutter rendering fallback prevents a blank screen after an unexpected widget error.
- Payment UX exposes the real server-authoritative lifecycle without ever presenting a locally-created payment intent as completed payment.
- Reusable error and empty-state components are available for remaining screens.
- Admin country operations now has explicit loading and saving states.
- Admin media review actions show progress and prevent duplicate clicks.
- Admin responsive tables remain usable on small screens.
- Next.js admin route-level loading and error fallback screens were added.
- Existing v13 security controls, country operations, payment guardian, video review, privacy controls and global capabilities were preserved.

### Deliberate security behavior
- Payment success remains provider/webhook authoritative.
- Provider webhook signature verification remains mandatory.
- Uncertain operations are not presented as completed.
- Security/fraud decisions remain server-side and auditable.
- No claim is made that fraud can be eliminated; controls are designed to reduce abuse and surface signals for human review.

### Build note
This runtime does not contain the Flutter SDK or project node_modules. Therefore this archive has been statically edited and inspected, but no Flutter build, NestJS build or Next.js production build is claimed as completed.
