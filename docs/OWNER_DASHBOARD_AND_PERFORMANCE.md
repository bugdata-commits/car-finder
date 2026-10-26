# Owner dashboard and performance update

## Supabase access

CarFinder remains connected to the active, healthy Supabase project `eeodzwzxpquqwtvccqab`. Authentication uses Supabase Auth. Owner authorization is enforced by the existing `seller_id = auth.uid()` ownership policies; the browser dashboard never replaces those database checks.

## Owner roles

Signed-in owners now get one dashboard with three secure views: all listings, sale listings, and rental listings. Counts show total inventory, sale inventory and rental inventory. Dealer/private profile context changes the owner-facing dashboard note, while listing ownership remains enforced by Supabase RLS. Administrators continue to use the existing separate admin controls.

## Fast loading changes

- Public listing queries request only the columns the interface uses.
- Listing cards render as soon as the database response arrives.
- Private Supabase photo URLs are signed in the background and cards refresh when photos are ready.
- Independent profile and admin checks run concurrently after sign-in.
- Supabase connection preconnect is enabled.
- Public listing startup has a bounded timeout and a usable degraded state instead of an endless spinner.
- Delete actions include the owner filter in the update request as an additional client-side safety check; RLS remains authoritative.
- The applied migration `20261026212500_optimize_owner_dashboard_queries.sql` adds review-event foreign-key indexes and keeps the same owner/admin access decisions while using init-plan-friendly auth predicates.

## Contact/loading note

The published site responds successfully and the active Supabase project is healthy. If a particular device still cannot reach the site, test both the public URL and the device network/browser cache; the app now reports a connection delay instead of silently waiting forever.
