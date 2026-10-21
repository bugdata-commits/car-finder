# CarFinder

Zimbabwe-focused vehicle marketplace for buyers and sellers, with Supabase authentication, saved listings, vehicle comparison, seller dashboards, and admin moderation.

**Live site:** https://bugdata-commits.github.io/car-finder/
**Repository:** https://github.com/bugdata-commits/car-finder

The browser app is `index.html` (vanilla JavaScript); images and supporting assets are in `assets/`, and the self-hosted Supabase client is in `vendor/`. Production database migrations are versioned in `supabase/migrations/`.

- [Supabase setup](docs/SUPABASE.md)
- [Security review](docs/SECURITY_REVIEW.md)
- [Changelog](docs/CHANGELOG.md)

Admin access is controlled by the Supabase `public.admins` allowlist and database RLS/triggers. Never put a Supabase service-role key or other private credential in browser code.
