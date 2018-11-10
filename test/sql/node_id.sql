\set ECHO none
\set QUIET 1
BEGIN;
\i sql/explanation.sql

-- Mock clock_timestamp().
CREATE SCHEMA mock;
CREATE OR REPLACE FUNCTION mock.clock_timestamp(
) RETURNS timestamptz LANGUAGE SQL AS $$
    SELECT '2010-07-19 11:01:03.306399+00'::timestamptz;
$$;

SET search_path = mock,public,pg_catalog;

-- Make sure the generated ID is what we think it should be.
SELECT node_id = md5(pg_backend_pid()::text || clock_timestamp())
    AS "Node ID is PID || clock timestamp"
  FROM parse_node('<Plan><Node-Type>Aggregate</Node-Type></Plan>');

ROLLBACK;
