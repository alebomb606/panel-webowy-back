-- PROCEDURE: public.regular_daily_cleanup()
--
-- This procedure does a cleanup for production tables, 
-- cutting route records and sensor records older than 
-- 14 days. Needs to run daily.
-- 
-- Set up regular daemon or scheduled job to execute aside
-- top load hours (business hours).
--
-- Possible option: https://github.com/citusdata/pg_cron
-- 

-- DROP PROCEDURE public.regular_daily_cleanup();

CREATE OR REPLACE PROCEDURE public.regular_daily_cleanup(
	)
LANGUAGE 'plpgsql'

AS $BODY$BEGIN
	DELETE FROM trailer_sensor_readings 
		WHERE read_at < CURRENT_TIMESTAMP - interval '14 days';

	DELETE FROM route_logs
		WHERE updated_at < CURRENT_TIMESTAMP - interval '14 days';

	COMMIT;
END;$BODY$;
