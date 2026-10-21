# Supabase backend

CarFinder’s production backend is Supabase project `eeodzwzxpquqwtvccqab`. GitHub Pages uses the browser-safe publishable key; no service-role key belongs in `index.html`.

## Tables and access model

- `profiles` stores seller display/contact details and admin-controlled `verified`/`suspended` flags.
- `listings` stores vehicle details. New submissions are `pending`; the public sees only active listings whose sellers are not suspended. Sellers can read their own listings but cannot self-publish.
- `admins` is the administrator allowlist keyed by Supabase Auth user ID. The website checks the signed-in user against this table; showing/hiding admin navigation is not the security boundary.
- `favorites` stores saved listing IDs and is owner-scoped. Signed-out visitors can open the Favorites route and see its sign-in-required state.
- `listing_review_events` stores the approval/rejection audit log. Admins can read it; a database trigger records decisions. `get_listing_review_analytics()` checks admin membership before returning counts.

RLS is enabled on all five application tables and `storage.objects`. Profile reads are restricted to the signed-in user, admins, and sellers with active listings (unless suspended). Admin-only seller flags and featured status are protected by database triggers. Review decisions are recorded server-side.

## Listing photo storage

The `listing-photos` bucket is private. The site creates one-hour signed URLs in batches. Public signed reads are allowed only for photos attached to active listings whose sellers are not suspended; authenticated sellers can read objects under their own user-ID folder, and admins can read any listing photo for moderation. New uploads store object paths in `listings.image_urls`; legacy full public URLs are recognized and converted at read time.

Accepted formats: JPEG, PNG, WebP. Maximum size: 10 MiB per object. Frontend validation mirrors the bucket setting, while Storage is the authoritative upload constraint.

## Versioned migrations

Apply these migrations in order after creating the base tables, existing listing-review trigger/RPC, and initial RLS setup:

1. `supabase/migrations/20261021125100_guard_admin_flags_and_listing_photo_uploads.sql`
2. `supabase/migrations/20261021130000_scope_profile_and_photo_reads.sql`
3. `supabase/migrations/20261021131000_lock_trigger_function_search_paths.sql`

All three have been applied to the existing production project. The second migration makes the photo bucket private, so publish the signed-URL-capable frontend first.

## Operational safety

Do not place service-role credentials, database passwords, or email-provider API keys in frontend code. Keep RLS enabled on new tables and scope policies with `auth.uid()` and/or `public.admins` membership. Administrator membership should be changed only through trusted database operations. RLS is not forced, so the database owner and Supabase `service_role` remain trusted backend roles that bypass RLS.
