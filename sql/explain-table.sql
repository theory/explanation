-- Adjust this setting to control where the objects get created.
SET search_path = public;

SET client_min_messages = warning;

CREATE OR REPLACE FUNCTION parse_node(
    node XML,
    parent_id TEXT DEFAULT NULL,
    runtime   FLOAT DEFAULT NULL
) RETURNS TABLE(
    "Node ID"               TEXT,
    "Parent ID"             TEXT,
    "Node Type"             TEXT,
    "Total Runtime"         FLOAT,
    "Strategy"              TEXT,
    "Operation"             TEXT,
    "Startup Cost"          FLOAT,
    "Total Cost"            FLOAT,
    "Plan Rows"             FLOAT,
    "Plan Width"            INTEGER,
    "Actual Startup Time"   FLOAT, -- Change to interval?
    "Actual Total Time"     FLOAT, -- Change to interval?
    "Actual Rows"           FLOAT,
    "Actual Loops"          FLOAT,
    "Parent Relationship"   TEXT,
    "Sort Key"              TEXT[],
    "Sort Method"           TEXT[],
    "Sort Space Used"       BIGINT,
    "Sort Space Type"       TEXT,
    "Join Type"             TEXT,
    "Join Filter"           TEXT,
    "Hash Cond"             TEXT,
    "Relation Name"         TEXT,
    "Alias"                 TEXT,
    "Scan Direction"        TEXT,
    "Index Name"            TEXT,
    "Index Cond"            TEXT,
    "Recheck Cond"          TEXT,
    "TID Cond"              TEXT,
    "Merge Cond"            TEXT,
    "Subplan Name"          TEXT,
    "Function Name"         TEXT,
    "Function Call"         TEXT,
    "Filter"                TEXT,
    "One-Time Filter"       TEXT,
    "Command"               TEXT,
    "Shared Hit Blocks"     BIGINT,
    "Shared Read Blocks"    BIGINT,
    "Shared Written Blocks" BIGINT,
    "Local Hit Blocks"      BIGINT,
    "Local Read Blocks"     BIGINT,
    "Local Written Blocks"  BIGINT,
    "Temp Read Blocks"      BIGINT,
    "Temp Written Blocks"   BIGINT,
    "Output"                TEXT[],
    "Hash Buckets"          BIGINT,
    "Hash Batches"          BIGINT,
    "Original Hash Batches" BIGINT,
    "Peak Memory Usage"     BIGINT,
    "Schema"                TEXT,
    "CTE Name"              TEXT
) LANGUAGE plpgsql AS $$
DECLARE
    plans   xml[] := xpath('/Plan/Plans/Plan', node);
    node_id TEXT  := md5(pg_backend_pid()::text || clock_timestamp());
BEGIN
    RETURN QUERY SELECT
        node_id,
        parent_id,
        (xpath('/Plan/Node-Type/text()', node))[1]::text,
        runtime,
        (xpath('/Plan/Strategy/text()', node))[1]::text,
        (xpath('/Plan/Operation/text()', node))[1]::text,
        (xpath('/Plan/Startup-Cost/text()', node))[1]::text::FLOAT,
        (xpath('/Plan/Total-Cost/text()', node))[1]::text::FLOAT,
        (xpath('/Plan/Plan-Rows/text()', node))[1]::text::FLOAT,
        (xpath('/Plan/Plan-Width/text()', node))[1]::text::INTEGER,
        (xpath('/Plan/Actual-Startup-Time/text()', node))[1]::text::FLOAT,
        (xpath('/Plan/Actual-Total-Time/text()', node))[1]::text::FLOAT,
        (xpath('/Plan/Actual-Rows/text()', node))[1]::text::FLOAT,
        (xpath('/Plan/Actual-Loops/text()', node))[1]::text::FLOAT,
        (xpath('/Plan/Parent-Relationship/text()', node))[1]::text,
        xpath('/Plan/Sort-Key/Item/text()', node)::text[],
        xpath('/Plan/Sort-Method/Item/text()', node)::text[],
        (xpath('/Plan/Sort-Space-Used/text()', node))[1]::text::bigint,
        (xpath('/Plan/Sort-Space-Type/text()', node))[1]::text,
        (xpath('/Plan/Join-Type/text()', node))[1]::text,
        (xpath('/Plan/Join-Filter/text()', node))[1]::text,
        (xpath('/Plan/Hash-Cond/text()', node))[1]::text,
        (xpath('/Plan/Relation-Name/text()', node))[1]::text,
        (xpath('/Plan/Alias/text()', node))[1]::text,
        (xpath('/Plan/Scan-Direction/text()', node))[1]::text,
        (xpath('/Plan/Index-Name/text()', node))[1]::text,
        (xpath('/Plan/Index-Cond/text()', node))[1]::text,
        (xpath('/Plan/Recheck-Cond/text()', node))[1]::text,
        (xpath('/Plan/TID-Cond/text()', node))[1]::text,
        (xpath('/Plan/Merge-Cond/text()', node))[1]::text,
        (xpath('/Plan/Subplan-Name/text()', node))[1]::text,
        (xpath('/Plan/Function-Name/text()', node))[1]::text,
        (xpath('/Plan/Function-Call/text()', node))[1]::text,
        (xpath('/Plan/Filter/text()', node))[1]::text,
        (xpath('/Plan/One-Time-Filter/text()', node))[1]::text,
        (xpath('/Plan/Command/text()', node))[1]::text,
        (xpath('/Plan/Shared-Hit-Blocks/text()', node))[1]::text::bigint,
        (xpath('/Plan/Shared-Read-Blocks/text()', node))[1]::text::bigint,
        (xpath('/Plan/Shared-Written-Blocks/text()', node))[1]::text::bigint,
        (xpath('/Plan/Local-Hit-Blocks/text()', node))[1]::text::bigint,
        (xpath('/Plan/Local-Read-Blocks/text()', node))[1]::text::bigint,
        (xpath('/Plan/Local-Written-Blocks/text()', node))[1]::text::bigint,
        (xpath('/Plan/Temp-Read-Blocks/text()', node))[1]::text::bigint,
        (xpath('/Plan/Temp-Written-Blocks/text()', node))[1]::text::bigint,
        xpath('/Plan/Output/Item/text()', node)::text[],
        (xpath('/Plan/Hash-Buckets/text()', node))[1]::text::bigint,
        (xpath('/Plan/Hash-Batches/text()', node))[1]::text::bigint,
        (xpath('/Plan/Original-Hash-Batches/text()', node))[1]::text::bigint,
        (xpath('/Plan/Peak-Memory-Usage/text()', node))[1]::text::bigint,
        (xpath('/Plan/Schema/text()', node))[1]::text,
        (xpath('/Plan/CTE-Name/text()', node))[1]::text
    ;

    -- Recurse.
    IF plans IS NOT NULL THEN
        FOR node IN SELECT unnest(plans) LOOP
            RETURN QUERY SELECT * FROM parse_node(node, node_id);
        END LOOP;
    END IF;
END;
$$;

CREATE OR REPLACE FUNCTION plan(
    q TEXT,
    a BOOLEAN DEFAULT FALSE
) RETURNS TABLE(
    "Node ID"               TEXT,
    "Parent ID"             TEXT,
    "Node Type"             TEXT,
    "Total Runtime"         FLOAT,
    "Strategy"              TEXT,
    "Operation"             TEXT,
    "Startup Cost"          FLOAT,
    "Total Cost"            FLOAT,
    "Plan Rows"             FLOAT,
    "Plan Width"            INTEGER,
    "Actual Startup Time"   FLOAT,
    "Actual Total Time"     FLOAT,
    "Actual Rows"           FLOAT,
    "Actual Loops"          FLOAT,
    "Parent Relationship"   TEXT,
    "Sort Key"              TEXT[],
    "Sort Method"           TEXT[],
    "Sort Space Used"       BIGINT,
    "Sort Space Type"       TEXT,
    "Join Type"             TEXT,
    "Join Filter"           TEXT,
    "Hash Cond"             TEXT,
    "Relation Name"         TEXT,
    "Alias"                 TEXT,
    "Scan Direction"        TEXT,
    "Index Name"            TEXT,
    "Index Cond"            TEXT,
    "Recheck Cond"          TEXT,
    "TID Cond"              TEXT,
    "Merge Cond"            TEXT,
    "Subplan Name"          TEXT,
    "Function Name"         TEXT,
    "Function Call"         TEXT,
    "Filter"                TEXT,
    "One-Time Filter"       TEXT,
    "Command"               TEXT,
    "Shared Hit Blocks"     BIGINT,
    "Shared Read Blocks"    BIGINT,
    "Shared Written Blocks" BIGINT,
    "Local Hit Blocks"      BIGINT,
    "Local Read Blocks"     BIGINT,
    "Local Written Blocks"  BIGINT,
    "Temp Read Blocks"      BIGINT,
    "Temp Written Blocks"   BIGINT,
    "Output"                TEXT[],
    "Hash Buckets"          BIGINT,
    "Hash Batches"          BIGINT,
    "Original Hash Batches" BIGINT,
    "Peak Memory Usage"     BIGINT,
    "Schema"                TEXT,
    "CTE Name"              TEXT
) LANGUAGE plpgsql AS $$
DECLARE
    plan  xml;
    node  xml;
    xmlns text[] := ARRAY[ARRAY['e', 'http://www.postgresql.org/2009/explain']];
BEGIN
    -- Get the plan.
    EXECUTE 'EXPLAIN (format xml'
         || CASE WHEN a THEN ', analyze true' ELSE '' END
         || ') ' || q INTO plan;

    RETURN QUERY SELECT * FROM parse_node(
        (xpath('/e:explain/e:Query/e:Plan', plan, xmlns))[1],
        NULL,
        (xpath('/e:explain/e:Query/e:Total-Runtime/text()', plan, xmlns))[1]::text::float
    );
END;
$$;