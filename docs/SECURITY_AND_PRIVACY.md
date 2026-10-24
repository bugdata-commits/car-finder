# CarFinder security, privacy and policy implementation

**Effective date:** 24 October 2026

The website now includes Terms & Conditions, Privacy Policy, and Security & Safety pages. The wording is a practical implementation draft for a Zimbabwe-focused marketplace and must be reviewed by a Zimbabwe-qualified lawyer or data-protection professional before final adoption.

## Implemented controls

- HTML-escape user-controlled values before rendering them into the DOM.
- Allowlist external image URLs to the private Supabase listing-photo signed-URL path and fall back to a placeholder for other URLs.
- Restrict WhatsApp links to plausible digit-only numbers and use encoded message text.
- Normalize and bound user-entered text, numbers, enum fields and descriptions before database writes.
- Require Terms & Conditions and Privacy Policy acknowledgement for accounts and listings.
- Restrict photo uploads to six JPEG/PNG/WebP files, 10 MiB each, with extension and MIME checks and generated storage names.
- Add browser CSP, referrer policy, permissions policy and frame-ancestor protections.
- Preserve Supabase RLS, private storage and database-side moderation controls.

## Residual work

No client-side hardening can guarantee that a public internet service cannot be hacked. Keep Supabase service-role credentials server-side, review admin membership, enable leaked-password protection in Supabase Auth, and arrange periodic dependency review and penetration testing.

## Sources

- [Zimbabwe Cyber and Data Protection Act No. 5 of 2021](https://www.potraz.gov.zw/wp-content/uploads/2022/02/Data-Protection-Act-5-of-2021.pdf)
- [DLA Piper Zimbabwe data protection overview](https://www.dlapiperdataprotection.com/index.html?t=law&c=ZW)
