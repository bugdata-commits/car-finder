-- Prevent sellers from changing administrator-controlled state, and constrain uploads.

CREATE OR REPLACE FUNCTION public.guard_admin_profile_flags()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $function$
DECLARE
  actor_id uuid := auth.uid();
  protected_change boolean := false;
BEGIN
  IF TG_OP = 'INSERT' THEN
    protected_change := COALESCE(NEW.verified, false) OR COALESCE(NEW.suspended, false);
  ELSE
    protected_change := OLD.verified IS DISTINCT FROM NEW.verified
      OR OLD.suspended IS DISTINCT FROM NEW.suspended;
  END IF;

  -- A NULL auth.uid() is reserved for trusted backend/database operations.
  -- API callers still have to pass the table's RLS policies before reaching this trigger.
  IF protected_change AND actor_id IS NOT NULL
     AND NOT EXISTS (SELECT 1 FROM public.admins AS a WHERE a.user_id = actor_id) THEN
    RAISE EXCEPTION 'Only an administrator can change seller verification or suspension flags'
      USING ERRCODE = '42501';
  END IF;
  RETURN NEW;
END;
$function$;

REVOKE ALL ON FUNCTION public.guard_admin_profile_flags() FROM PUBLIC, anon, authenticated;
DROP TRIGGER IF EXISTS profiles_guard_admin_flags ON public.profiles;
CREATE TRIGGER profiles_guard_admin_flags
BEFORE INSERT OR UPDATE OF verified, suspended ON public.profiles
FOR EACH ROW EXECUTE FUNCTION public.guard_admin_profile_flags();

CREATE OR REPLACE FUNCTION public.guard_admin_listing_featured()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $function$
DECLARE
  actor_id uuid := auth.uid();
  protected_change boolean := false;
BEGIN
  IF TG_OP = 'INSERT' THEN
    protected_change := COALESCE(NEW.featured, false);
  ELSE
    protected_change := OLD.featured IS DISTINCT FROM NEW.featured;
  END IF;

  -- A NULL auth.uid() is reserved for trusted backend/database operations.
  -- API callers still have to pass the table's RLS policies before reaching this trigger.
  IF protected_change AND actor_id IS NOT NULL
     AND NOT EXISTS (SELECT 1 FROM public.admins AS a WHERE a.user_id = actor_id) THEN
    RAISE EXCEPTION 'Only an administrator can change listing featured status'
      USING ERRCODE = '42501';
  END IF;
  RETURN NEW;
END;
$function$;

REVOKE ALL ON FUNCTION public.guard_admin_listing_featured() FROM PUBLIC, anon, authenticated;
DROP TRIGGER IF EXISTS listings_guard_admin_featured ON public.listings;
CREATE TRIGGER listings_guard_admin_featured
BEFORE INSERT OR UPDATE OF featured ON public.listings
FOR EACH ROW EXECUTE FUNCTION public.guard_admin_listing_featured();

UPDATE storage.buckets
SET file_size_limit = 10485760,
    allowed_mime_types = ARRAY['image/jpeg', 'image/png', 'image/webp']::text[]
WHERE id = 'listing-photos';
