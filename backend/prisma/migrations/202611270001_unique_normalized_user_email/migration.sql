-- Prevent duplicate accounts when email casing or surrounding whitespace differs.
-- Preserve existing accounts; stop with a clear error if a prior duplicate exists.
DO $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM "User"
    GROUP BY LOWER(BTRIM("email"))
    HAVING COUNT(*) > 1
  ) THEN
    RAISE EXCEPTION 'Duplicate Helpi user emails exist after normalization; resolve them before applying this migration.';
  END IF;
END $$;

UPDATE "User"
SET "email" = LOWER(BTRIM("email"))
WHERE "email" <> LOWER(BTRIM("email"));

CREATE UNIQUE INDEX "User_email_normalized_key"
ON "User" (LOWER(BTRIM("email")));
