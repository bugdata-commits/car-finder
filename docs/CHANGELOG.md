# Changelog

## 2026-10-21 — Moderation, privacy and responsive marketplace

The pending-review queue now becomes finger-friendly on phones, with a full-width Review button, a clear review modal, and prominent Approve/Reject controls. Admin listing-query failures are shown as actionable errors with a retry button rather than as an empty queue. Marketplace cards remain compact at four columns on desktop, three on laptop, two on tablet, and one on narrow phones.

Listing photos now use batched, one-hour signed URLs; new uploads store object paths. Unconditional public profile reads and bucket-wide public photo reads were removed. Public reads are scoped to active listings and non-suspended sellers, while sellers retain their own photo-folder access and admins can inspect submissions. The bucket enforces JPEG/PNG/WebP and a 10 MiB per-photo limit.

Database triggers protect seller verification/suspension and featured-listing flags, record listing-review decisions, and require admin membership for moderation. All public-schema `SECURITY DEFINER` functions now use an empty `search_path`; the timestamp trigger also uses an empty path. The three security migrations are versioned in `supabase/migrations/` and have been applied to production.

Signed-out visitors can open a direct `#/favorites` URL and see a sign-in-required state without being redirected to Sell. Cross-browser production checks passed in Chromium, Firefox, and WebKit: search filtering and clearing, mobile-menu open/close, responsive grid, direct Sell/Favorites links, and synthetic Review/Approve/Reject handlers. Private photo checks confirmed active-photo signing works, pending-photo signing is denied, and direct public photo URLs are private.

## Earlier work

See the marketplace handoff documents for the saved-cars, comparison, budget-planner, review analytics, CSV exports, and original deployment history.
