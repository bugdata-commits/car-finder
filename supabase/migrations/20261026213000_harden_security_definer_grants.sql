-- Keep security helper functions available to the policies that need them,
-- but remove them from the public API surface and revoke direct RPC execution.

CREATE SCHEMA IF NOT EXISTS private;
REVOKE ALL ON SCHEMA private FROM PUBLIC;
GRANT USAGE ON SCHEMA private TO anon, authenticated;

CREATE OR REPLACE FUNCTION private.is_active_listing_photo(object_name text)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = ''
AS $function$
  SELECT EXISTS (
    SELECT 1
    FROM public.listings AS l
    JOIN public.profiles AS seller ON seller.id = l.seller_id
    CROSS JOIN LATERAL unnest(COALESCE(l.image_urls, ARRAY[]::text[])) AS photo(url)
    WHERE l.status = 'active'
      AND seller.suspended IS FALSE
      AND (
        photo.url = object_name
        OR split_part(photo.url, '/storage/v1/object/public/listing-photos/', 2) = object_name
      )
  );
$function$;

CREATE OR REPLACE FUNCTION private.is_active_listing_seller(target_profile_id uuid)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = ''
AS $function$
  SELECT EXISTS (
    SELECT 1
    FROM public.listings AS l
    JOIN public.profiles AS seller ON seller.id = l.seller_id
    WHERE l.seller_id = target_profile_id
      AND l.status = 'active'
      AND seller.suspended IS FALSE
  );
$function$;

REVOKE ALL ON FUNCTION private.is_active_listing_photo(text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION private.is_active_listing_photo(text) TO anon, authenticated;
REVOKE ALL ON FUNCTION private.is_active_listing_seller(uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION private.is_active_listing_seller(uuid) TO anon, authenticated;

DROP POLICY IF EXISTS "Public can read active listing photos" ON storage.objects;
CREATE POLICY "Public can read active listing photos"
ON storage.objects
FOR SELECT TO anon, authenticated
USING (bucket_id = 'listing-photos' AND private.is_active_listing_photo(name));

DROP POLICY IF EXISTS "Public can read profiles of active sellers" ON public.profiles;
CREATE POLICY "Public can read profiles of active sellers"
ON public.profiles
FOR SELECT TO anon, authenticated
USING (private.is_active_listing_seller(id));

REVOKE ALL ON FUNCTION public.is_active_listing_photo(text) FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION public.is_active_listing_seller(uuid) FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION public.capture_listing_review_event() FROM PUBLIC, anon, authenticated;
