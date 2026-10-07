# Helpi Video & Anonymous Identity Design

## Video evidence

People may attach a short video to a help request so verifiers and potential helpers can understand the situation more clearly.

### Safety rules
- Videos are uploaded directly to private object storage using short-lived signed URLs.
- Mobile UI limits recordings to 3 minutes and the backend accepts video files up to 100 MB.
- Uploaded video evidence is never public by default.
- Video evidence starts in a human privacy/safety review state.
- Only an authorized reviewer can approve a video for public playback.
- Public playback uses a short-lived signed URL and is available only when the case itself is published and verified.
- Users are warned not to expose passwords, OTPs, card details, exact home addresses or unnecessary images of children.
- Helpi should add automated malware/content scanning and optional redaction/transcoding before production public playback.

## Anonymous public identity

Helpi supports three public identity modes:

- `REAL_NAME` — the public case can show the person's chosen real name.
- `ALIAS` — the public case shows a chosen alias.
- `ANONYMOUS` — the public case shows an anonymous Helpi identity.

Anonymous does **not** mean that Helpi has no identity information. The platform may retain the minimum identity information required for account security, fraud prevention, verification, payment compliance, safeguarding and lawful requests.

The goal is **public privacy with accountable platform verification**.
