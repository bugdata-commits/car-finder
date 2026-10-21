# CarFinder security review

**Reviewed:** 2026-10-21
**Production backend:** Supabase project `eeodzwzxpquqwtvccqab`

## Scope and result

The review covered every RLS policy on the five CarFinder public tables (`admins`, `favorites`, `listing_review_events`, `listings`, `profiles`), plus `storage.objects`; database triggers and public functions; Farai’s administrator membership; and listing-photo storage. RLS is enabled on all five application tables and Storage objects. It is not forced, so the database owner and Supabase `service_role` remain privileged server-side roles and must never be exposed in browser code.

The main exposure found was unconditional public profile access and a bucket-wide public photo-read policy. Both have been removed. Public access to profile and photo data now follows active, non-suspended listing visibility; pending photos are private to the seller and admins.

## Current row-level security model

| Resource | Effective access |
| --- | --- |
| `admins` | A signed-in user can check only their own allowlist membership. Farai’s membership was verified (exact account match count: 1). |
| `favorites` | Users manage only their own rows (`user_id = auth.uid()`). |
| `listing_review_events` | Admins read the audit log. Review decisions are inserted by a database trigger; ordinary clients have no insert, update, or delete policy. |
| `listings` | Public reads are limited to active listings with non-suspended sellers; sellers may read their own records. Sellers insert only their own pending rows, update only their own listings into the allowed `pending`/`sold` states, and delete only their own rows. Admins may read and update listings. |
| `profiles` | Users read their own profile; admins read all profiles; the public reads a seller profile only while that seller has an active listing and is not suspended. The unconditional public read policy is gone. Admin-only `verified`/`suspended` flags are protected by a database trigger. |
| `storage.objects` | Public signed reads are limited to photos attached to active listings of non-suspended sellers. Sellers read/upload/update/delete only within their own user-ID folder. Admins can read listing photos for moderation. |

## Database and storage safeguards

Sellers cannot set/clear `listings.featured` or self-change their `verified`/`suspended` profile flags; database triggers enforce these restrictions even for direct API requests. A pending-to-active/rejected transition requires an allowlisted admin and is recorded by the database review trigger.

The `listing-photos` bucket is private, limited to 10 MiB per object, and accepts JPEG, PNG, and WebP only. New uploads store object paths in `listings.image_urls`; the frontend requests batched one-hour signed URLs. Legacy full public URLs are recognized and converted to signed URLs.

All six public-schema `SECURITY DEFINER` functions have an explicitly empty `search_path`. The timestamp trigger function also uses an empty path; the analytics function is invoker-security and uses an empty path. Trigger attachments and function settings were verified after migration.

## Production verification

The production policy inventory confirms RLS is enabled for every application table and Storage objects, with no unconditional public profile read or bucket-wide public photo read. The bucket reports `public = false` with its 10 MiB and MIME restrictions. Anonymous access tests confirmed an active-listing photo can be signed, a non-active photo cannot be signed, and a direct public-bucket request for a non-active photo returns HTTP 400. The public marketplace continues to load the active seller profile and signed image without JavaScript errors.

Production HTTPS tests passed in Chromium, Firefox, and WebKit. Search filters to the visible “0 listings” state for a no-match query and restores the car when cleared. The mobile menu opens and closes; responsive cards render 1/2/3/4 columns at mobile/tablet/laptop/desktop widths. A synthetic pending listing was used to click Review, Approve, and Reject; a stubbed handler verified the intended `active`/`rejected` actions without changing a real listing. Direct `#/sell` and `#/favorites` links now remain on their requested pages; a guest sees the existing “Sign in required” state on Favorites.

## Versioned migrations

1. `supabase/migrations/20261021125100_guard_admin_flags_and_listing_photo_uploads.sql` — protects admin-only profile/listing flags and constrains upload size/type.
2. `supabase/migrations/20261021130000_scope_profile_and_photo_reads.sql` — scopes profile/photo reads and makes the photo bucket private.
3. `supabase/migrations/20261021131000_lock_trigger_function_search_paths.sql` — hardens signup/timestamp trigger function path settings.

All three migrations have been applied to the production project. On a new project, create the base schema and existing marketplace/audit functions first, then apply these migrations in order. Publish the signed-URL-capable frontend before making the photo bucket private.

## Residual considerations

RLS protects browser roles, not the database owner or Supabase `service_role`, which intentionally bypass RLS. Keep those credentials server-side and review `public.admins` membership periodically.
