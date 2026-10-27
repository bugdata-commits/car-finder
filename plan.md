# CarFinder owner dashboard and performance plan

## Design movement

A focused marketplace workspace: clear role cues, compact metrics, segmented sale/rental controls, and immediate content rendering.

## Implementation

- Preserve Supabase Auth, owner-scoped `seller_id` queries, RLS, and the existing admin role.
- Extend the authenticated owner dashboard with all/sale/rental views and inventory counts.
- Render public listing cards immediately after the database response; sign private storage photos in the background.
- Parallelize independent authentication profile/admin checks and warm the Supabase connection.
- Bound the public listing request so a slow dependency produces a usable page instead of an indefinite loading state.

## Feature removal

Remove Blog and AI Match from the user journey: navigation, homepage teaser, page markup, route declarations, embedded data, event handlers, and feature-only styling. Preserve buying, rentals, selling, authentication, owner dashboard, favorites, admin, and legal/security pages.
