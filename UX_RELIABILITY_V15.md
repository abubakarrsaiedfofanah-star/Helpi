# Helpi v15 — UX + Reliability Pass

Applied on top of v14 GUI.

## Mobile app
- Unified page transitions, snackbar styling and scroll behavior.
- Network requests now have timeouts, safe user-facing errors and one automatic retry for GET requests.
- Startup rendering has a controlled fallback instead of a blank/crashed screen.
- Home discovery shows a retryable offline/network error state instead of silently failing.
- Payment UI now communicates the lifecycle: Ready → Checking → Creating secure payment → Processing/provider confirmation. It never presents creation of a payment intent as completed payment.
- Reusable error and empty states were added for consistent future screens.

## Admin
- Country configuration and media-review workflows now expose loading/saving states.
- Review actions are disabled while an item is being updated.
- Mobile tables remain horizontally scrollable instead of breaking the layout.
- Added keyboard focus, touch target and reduced-motion polish on top of v14.

## Security posture
- Server remains authoritative for payment status.
- Provider webhook signature verification remains required.
- No frontend control can mark a transaction as succeeded.
- Errors shown to users avoid exposing low-level exception details.

## Verification
- Source files were statically inspected after edits. Flutter/Dart and npm dependencies are not installed in this runtime, so a real Flutter build and NestJS/Next.js compilation could not be truthfully claimed here.
