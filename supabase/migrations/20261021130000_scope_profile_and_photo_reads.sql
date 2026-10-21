-- Limit profile and listing-photo reads to the minimum required by each user.
-- Existing listings.image_urls may contain public URLs from the former bucket mode;
-- new frontend writes store object paths. Both formats are handled below.

CREATE OR REPLACE FUNCTION public.is_active_listing_seller(target_profile_id uuid)
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
REVOKE ALL ON FUNCTION public.is_active_listing_seller(uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.is_active_listing_seller(uuid) TO anon, authenticated;

DROP POLICY IF EXISTS "Profiles are publicly readable" ON public.profiles;
DROP POLICY IF EXISTS "Users can read their own profile" ON public.profiles;
DROP POLICY IF EXISTS "Admins can read all profiles" ON public.profiles;
DROP POLICY IF EXISTS "Public can read profiles of active sellers" ON public.profiles;

CREATE POLICY "Users can read their own profile"
ON public.profiles FOR SELECT TO authenticated
USING (id = (SELECT auth.uid()));

CREATE POLICY "Admins can read all profiles"
ON public.profiles FOR SELECT TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.admins AS a
    WHERE a.user_id = (SELECT auth.uid())
  )
);

CREATE POLICY "Public can read profiles of active sellers"
ON public.profiles FOR SELECT TO anon, authenticated
USING (public.is_active_listing_seller(id));

CREATE OR REPLACE FUNCTION public.is_active_listing_photo(object_name text)
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
REVOKE ALL ON FUNCTION public.is_active_listing_photo(text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.is_active_listing_photo(text) TO anon, authenticated;

DROP POLICY IF EXISTS "Public read access to listing photos" ON storage.objects;
DROP POLICY IF EXISTS "Public can read active listing photos" ON storage.objects;
DROP POLICY IF EXISTS "Sellers can read their own listing photos" ON storage.objects;
DROP POLICY IF EXISTS "Admins can read listing photos" ON storage.objects;

CREATE POLICY "Public can read active listing photos"
ON storage.objects FOR SELECT TO anon, authenticated
USING (
  bucket_id = 'listing-photos'
  AND public.is_active_listing_photo(name)
);

CREATE POLICY "Sellers can read their own listing photos"
ON storage.objects FOR SELECT TO authenticated
USING (
  bucket_id = 'listing-photos'
  AND (storage.foldername(name))[1] = (SELECT auth.uid())::text
);

CREATE POLICY "Admins can read listing photos"
ON storage.objects FOR SELECT TO authenticated
USING (
  bucket_id = 'listing-photos'
  AND EXISTS (
    SELECT 1 FROM public.admins AS a
    WHERE a.user_id = (SELECT auth.uid())
  )
);

UPDATE storage.buckets
SET public = false,
    file_size_limit = 10485760,
    allowed_mime_types = ARRAY['image/jpeg', 'image/png', 'image/webp']::text[]
WHERE id = 'listing-photos';
