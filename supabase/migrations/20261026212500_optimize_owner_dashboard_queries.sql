-- Improve owner dashboard and admin review query performance without changing access decisions.
-- RLS remains enabled and ownership/admin predicates remain the same.

CREATE INDEX IF NOT EXISTS listing_review_events_listing_id_idx
  ON public.listing_review_events (listing_id);

CREATE INDEX IF NOT EXISTS listing_review_events_reviewer_id_idx
  ON public.listing_review_events (reviewer_id);

DROP POLICY IF EXISTS "Sellers can create their own pending listings" ON public.listings;
CREATE POLICY "Sellers can create their own pending listings"
ON public.listings
FOR INSERT TO public
WITH CHECK ((select auth.uid()) = seller_id AND status = 'pending');

DROP POLICY IF EXISTS "Sellers can update their own listings without publishing" ON public.listings;
CREATE POLICY "Sellers can update their own listings without publishing"
ON public.listings
FOR UPDATE TO public
USING ((select auth.uid()) = seller_id)
WITH CHECK ((select auth.uid()) = seller_id AND status IN ('pending', 'sold'));

DROP POLICY IF EXISTS "Admins can read listing review events" ON public.listing_review_events;
CREATE POLICY "Admins can read listing review events"
ON public.listing_review_events
FOR SELECT TO authenticated
USING (EXISTS (
  SELECT 1 FROM public.admins AS a
  WHERE a.user_id = (select auth.uid())
));
