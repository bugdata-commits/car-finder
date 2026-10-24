-- Add support for listings that are offered for rent as well as sale listings.
ALTER TABLE public.listings
  ADD COLUMN IF NOT EXISTS listing_type text NOT NULL DEFAULT 'sale',
  ADD COLUMN IF NOT EXISTS rental_period text;

UPDATE public.listings
SET listing_type = 'sale'
WHERE listing_type IS NULL OR listing_type = '';

ALTER TABLE public.listings
  DROP CONSTRAINT IF EXISTS listings_listing_type_check,
  DROP CONSTRAINT IF EXISTS listings_rental_period_check,
  ADD CONSTRAINT listings_listing_type_check CHECK (listing_type IN ('sale', 'rent')),
  ADD CONSTRAINT listings_rental_period_check CHECK (rental_period IS NULL OR rental_period IN ('per day', 'per week', 'per month'));
