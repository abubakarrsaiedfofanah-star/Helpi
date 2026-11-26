-- The mobile/web clients must use the Helpi API, never Supabase's public Data API.
-- The API connects with the private PostgreSQL owner role; client roles get no policies.
DO $helpi_enable_rls$
DECLARE
  target RECORD;
BEGIN
  FOR target IN
    SELECT tablename
    FROM pg_tables
    WHERE schemaname = 'public'
      AND tablename <> '_prisma_migrations'
  LOOP
    EXECUTE format('ALTER TABLE %I.%I ENABLE ROW LEVEL SECURITY', 'public', target.tablename);
  END LOOP;
END;
$helpi_enable_rls$;
