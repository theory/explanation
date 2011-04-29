CREATE TYPE trigger_plan AS (
    trigger_name    TEXT,
    constraint_name TEXT,
    relation        TEXT,
    time            INTERVAL,
    calls           FLOAT
);

CREATE OR REPLACE FUNCTION parse_triggers(
    triggers  XML[]
) RETURNS SETOF trigger_plan LANGUAGE plpgsql AS $$
DECLARE
    trig xml;
BEGIN
    IF triggers IS NOT NULL THEN
        FOR trig IN SELECT unnest(triggers) LOOP
            RETURN QUERY SELECT
                (xpath('/Trigger/Trigger-Name/text()', trig))[1]::text,
                (xpath('/Trigger/Constraint-Name/text()', trig))[1]::text,
                (xpath('/Trigger/Relation/text()', trig))[1]::text,
                ((xpath('/Trigger/Time/text()', trig))[1]::text || ' ms')::interval,
                (xpath('/Trigger/Calls/text()', trig))[1]::text::float;
        END LOOP;
    END IF;
END;
$$;

CREATE OR REPLACE FUNCTION parse_node(
    node       XML,
    parent_id  TEXT           DEFAULT NULL,
    runtime    INTERVAL       DEFAULT NULL,
    trigs      trigger_plan[] DEFAULT NULL
) RETURNS TABLE(
    node_id               TEXT,
    parent_id             TEXT,
    node_type             TEXT,
    total_runtime         INTERVAL,
    strategy              TEXT,
    operation             TEXT,
    startup_cost          FLOAT,
    total_cost            FLOAT,
    plan_rows             FLOAT,
    plan_width            INTEGER,
    actual_startup_time   INTERVAL,
    actual_total_time     INTERVAL,
    actual_rows           FLOAT,
    actual_loops          FLOAT,
    parent_relationship   TEXT,
    sort_key              TEXT[],
    sort_method           TEXT[],
    sort_space_used       BIGINT,
    sort_space_type       TEXT,
    join_type             TEXT,
    join_filter           TEXT,
    hash_cond             TEXT,
    relation_name         TEXT,
    alias                 TEXT,
    scan_direction        TEXT,
    index_name            TEXT,
    index_cond            TEXT,
    recheck_cond          TEXT,
    tid_cond              TEXT,
    merge_cond            TEXT,
    subplan_name          TEXT,
    function_name         TEXT,
    function_call         TEXT,
    filter                TEXT,
    one_time_filter       TEXT,
    command               TEXT,
    shared_hit_blocks     BIGINT,
    shared_read_blocks    BIGINT,
    shared_written_blocks BIGINT,
    local_hit_blocks      BIGINT,
    local_read_blocks     BIGINT,
    local_written_blocks  BIGINT,
    temp_read_blocks      BIGINT,
    temp_written_blocks   BIGINT,
    output                TEXT[],
    hash_buckets          BIGINT,
    hash_batches          BIGINT,
    original_hash_batches BIGINT,
    peak_memory_usage     BIGINT,
    schema                TEXT,
    cte_name              TEXT,
    triggers              trigger_plan[]
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
        ((xpath('/Plan/Actual-Startup-Time/text()', node))[1]::text || ' ms')::interval,
        ((xpath('/Plan/Actual-Total-Time/text()', node))[1]::text || ' ms')::interval,
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
        (xpath('/Plan/CTE-Name/text()', node))[1]::text,
        trigs
    ;

    -- Recurse.
    IF plans IS NOT NULL THEN
        FOR node IN SELECT unnest(plans) LOOP
            RETURN QUERY SELECT * FROM parse_node(node, node_id, runtime);
        END LOOP;
    END IF;
END;
$$;

CREATE OR REPLACE FUNCTION parse_node(
    cols       TEXT[],
    node       XML,
    parent_id  TEXT DEFAULT NULL,
    runtime    INTERVAL DEFAULT NULL,
    trigs      trigger_plan[] DEFAULT NULL
) RETURNS TABLE(
    node_id               TEXT,
    parent_id             TEXT,
    node_type             TEXT,
    total_runtime         INTERVAL,
    strategy              TEXT,
    operation             TEXT,
    startup_cost          FLOAT,
    total_cost            FLOAT,
    plan_rows             FLOAT,
    plan_width            INTEGER,
    actual_startup_time   INTERVAL,
    actual_total_time     INTERVAL,
    actual_rows           FLOAT,
    actual_loops          FLOAT,
    parent_relationship   TEXT,
    sort_key              TEXT[],
    sort_method           TEXT[],
    sort_space_used       BIGINT,
    sort_space_type       TEXT,
    join_type             TEXT,
    join_filter           TEXT,
    hash_cond             TEXT,
    relation_name         TEXT,
    alias                 TEXT,
    scan_direction        TEXT,
    index_name            TEXT,
    index_cond            TEXT,
    recheck_cond          TEXT,
    tid_cond              TEXT,
    merge_cond            TEXT,
    subplan_name          TEXT,
    function_name         TEXT,
    function_call         TEXT,
    filter                TEXT,
    one_time_filter       TEXT,
    command               TEXT,
    shared_hit_blocks     BIGINT,
    shared_read_blocks    BIGINT,
    shared_written_blocks BIGINT,
    local_hit_blocks      BIGINT,
    local_read_blocks     BIGINT,
    local_written_blocks  BIGINT,
    temp_read_blocks      BIGINT,
    temp_written_blocks   BIGINT,
    output                TEXT[],
    hash_buckets          BIGINT,
    hash_batches          BIGINT,
    original_hash_batches BIGINT,
    peak_memory_usage     BIGINT,
    schema                TEXT,
    cte_name              TEXT,       
    triggers              trigger_plan[]
) LANGUAGE plpgsql AS $$
DECLARE
    plans   xml[] := xpath('/Plan/Plans/Plan', node);
    node_id TEXT  := md5(pg_backend_pid()::text || clock_timestamp());
BEGIN
    RETURN QUERY SELECT
        node_id,
        parent_id,
        CASE WHEN 'node_type'             = ANY(cols) THEN (xpath('/Plan/Node-Type/text()', node))[1]::text                                ELSE NULL END,
        runtime,
        CASE WHEN 'strategy'              = ANY(cols) THEN (xpath('/Plan/Strategy/text()', node))[1]::text                                 ELSE NULL END,
        CASE WHEN 'operation'             = ANY(cols) THEN (xpath('/Plan/Operation/text()', node))[1]::text                                ELSE NULL END,
        CASE WHEN 'startup_cost'          = ANY(cols) THEN (xpath('/Plan/Startup-Cost/text()', node))[1]::text::FLOAT                      ELSE NULL END,
        CASE WHEN 'total_cost'            = ANY(cols) THEN (xpath('/Plan/Total-Cost/text()', node))[1]::text::FLOAT                        ELSE NULL END,
        CASE WHEN 'plan_rows'             = ANY(cols) THEN (xpath('/Plan/Plan-Rows/text()', node))[1]::text::FLOAT                         ELSE NULL END,
        CASE WHEN 'plan_width'            = ANY(cols) THEN (xpath('/Plan/Plan-Width/text()', node))[1]::text::INTEGER                      ELSE NULL END,
        CASE WHEN 'actual_startup_time'   = ANY(cols) THEN ((xpath('/Plan/Actual-Startup-Time/text()', node))[1]::text || ' ms')::interval ELSE NULL END,
        CASE WHEN 'actual_total_time'     = ANY(cols) THEN ((xpath('/Plan/Actual-Total-Time/text()', node))[1]::text || ' ms')::interval   ELSE NULL END,
        CASE WHEN 'actual_rows'           = ANY(cols) THEN (xpath('/Plan/Actual-Rows/text()', node))[1]::text::FLOAT                       ELSE NULL END,
        CASE WHEN 'actual_loops'          = ANY(cols) THEN (xpath('/Plan/Actual-Loops/text()', node))[1]::text::FLOAT                      ELSE NULL END,
        CASE WHEN 'parent_relationship'   = ANY(cols) THEN (xpath('/Plan/Parent-Relationship/text()', node))[1]::text                      ELSE NULL END,
        CASE WHEN 'sort_key'              = ANY(cols) THEN xpath('/Plan/Sort-Key/Item/text()', node)::text[]                               ELSE NULL END,
        CASE WHEN 'sort_method'           = ANY(cols) THEN xpath('/Plan/Sort-Method/Item/text()', node)::text[]                            ELSE NULL END,
        CASE WHEN 'sort_space_used'       = ANY(cols) THEN (xpath('/Plan/Sort-Space-Used/text()', node))[1]::text::bigint                  ELSE NULL END,
        CASE WHEN 'sort_space_type'       = ANY(cols) THEN (xpath('/Plan/Sort-Space-Type/text()', node))[1]::text                          ELSE NULL END,
        CASE WHEN 'join_type'             = ANY(cols) THEN (xpath('/Plan/Join-Type/text()', node))[1]::text                                ELSE NULL END,
        CASE WHEN 'join_filter'           = ANY(cols) THEN (xpath('/Plan/Join-Filter/text()', node))[1]::text                              ELSE NULL END,
        CASE WHEN 'hash_cond'             = ANY(cols) THEN (xpath('/Plan/Hash-Cond/text()', node))[1]::text                                ELSE NULL END,
        CASE WHEN 'relation_name'         = ANY(cols) THEN (xpath('/Plan/Relation-Name/text()', node))[1]::text                            ELSE NULL END,
        CASE WHEN 'alias'                 = ANY(cols) THEN (xpath('/Plan/Alias/text()', node))[1]::text                                    ELSE NULL END,
        CASE WHEN 'scan_direction'        = ANY(cols) THEN (xpath('/Plan/Scan-Direction/text()', node))[1]::text                           ELSE NULL END,
        CASE WHEN 'index_name'            = ANY(cols) THEN (xpath('/Plan/Index-Name/text()', node))[1]::text                               ELSE NULL END,
        CASE WHEN 'index_cond'            = ANY(cols) THEN (xpath('/Plan/Index-Cond/text()', node))[1]::text                               ELSE NULL END,
        CASE WHEN 'recheck_cond'          = ANY(cols) THEN (xpath('/Plan/Recheck-Cond/text()', node))[1]::text                             ELSE NULL END,
        CASE WHEN 'tid_cond'              = ANY(cols) THEN (xpath('/Plan/TID-Cond/text()', node))[1]::text                                 ELSE NULL END,
        CASE WHEN 'merge_cond'            = ANY(cols) THEN (xpath('/Plan/Merge-Cond/text()', node))[1]::text                               ELSE NULL END,
        CASE WHEN 'subplan_name'          = ANY(cols) THEN (xpath('/Plan/Subplan-Name/text()', node))[1]::text                             ELSE NULL END,
        CASE WHEN 'function_name'         = ANY(cols) THEN (xpath('/Plan/Function-Name/text()', node))[1]::text                            ELSE NULL END,
        CASE WHEN 'function_call'         = ANY(cols) THEN (xpath('/Plan/Function-Call/text()', node))[1]::text                            ELSE NULL END,
        CASE WHEN 'filter'                = ANY(cols) THEN (xpath('/Plan/Filter/text()', node))[1]::text                                   ELSE NULL END,
        CASE WHEN 'one_time_filter'       = ANY(cols) THEN (xpath('/Plan/One-Time-Filter/text()', node))[1]::text                          ELSE NULL END,
        CASE WHEN 'command'               = ANY(cols) THEN (xpath('/Plan/Command/text()', node))[1]::text                                  ELSE NULL END,
        CASE WHEN 'shared_hit_blocks'     = ANY(cols) THEN (xpath('/Plan/Shared-Hit-Blocks/text()', node))[1]::text::bigint                ELSE NULL END,
        CASE WHEN 'shared_read_blocks'    = ANY(cols) THEN (xpath('/Plan/Shared-Read-Blocks/text()', node))[1]::text::bigint               ELSE NULL END,
        CASE WHEN 'shared_written_blocks' = ANY(cols) THEN (xpath('/Plan/Shared-Written-Blocks/text()', node))[1]::text::bigint            ELSE NULL END,
        CASE WHEN 'local_hit_blocks'      = ANY(cols) THEN (xpath('/Plan/Local-Hit-Blocks/text()', node))[1]::text::bigint                 ELSE NULL END,
        CASE WHEN 'local_read_blocks'     = ANY(cols) THEN (xpath('/Plan/Local-Read-Blocks/text()', node))[1]::text::bigint                ELSE NULL END,
        CASE WHEN 'local_written_blocks'  = ANY(cols) THEN (xpath('/Plan/Local-Written-Blocks/text()', node))[1]::text::bigint             ELSE NULL END,
        CASE WHEN 'temp_read_blocks'      = ANY(cols) THEN (xpath('/Plan/Temp-Read-Blocks/text()', node))[1]::text::bigint                 ELSE NULL END,
        CASE WHEN 'temp_written_blocks'   = ANY(cols) THEN (xpath('/Plan/Temp-Written-Blocks/text()', node))[1]::text::bigint              ELSE NULL END,
        CASE WHEN 'output'                = ANY(cols) THEN xpath('/Plan/Output/Item/text()', node)::text[]                                 ELSE NULL END,
        CASE WHEN 'hash_buckets'          = ANY(cols) THEN (xpath('/Plan/Hash-Buckets/text()', node))[1]::text::bigint                     ELSE NULL END,
        CASE WHEN 'hash_batches'          = ANY(cols) THEN (xpath('/Plan/Hash-Batches/text()', node))[1]::text::bigint                     ELSE NULL END,
        CASE WHEN 'original_hash_batches' = ANY(cols) THEN (xpath('/Plan/Original-Hash-Batches/text()', node))[1]::text::bigint            ELSE NULL END,
        CASE WHEN 'peak_memory_usage'     = ANY(cols) THEN (xpath('/Plan/Peak-Memory-Usage/text()', node))[1]::text::bigint                ELSE NULL END,
        CASE WHEN 'schema'                = ANY(cols) THEN (xpath('/Plan/Schema/text()', node))[1]::text                                   ELSE NULL END,
        CASE WHEN 'cte_name'              = ANY(cols) THEN (xpath('/Plan/CTE-Name/text()', node))[1]::text                                 ELSE NULL END,
        trigs
    ;

    -- Recurse.
    IF plans IS NOT NULL THEN
        FOR node IN SELECT unnest(plans) LOOP
            RETURN QUERY SELECT * FROM parse_node(cols, node, node_id, runtime);
        END LOOP;
    END IF;
END;
$$;

CREATE OR REPLACE FUNCTION explanation(
    query    TEXT,
    analyzed BOOLEAN DEFAULT FALSE,
    columns  TEXT[]  DEFAULT NULL
) RETURNS TABLE(
    planned_at            TIMESTAMPTZ,
    node_id               TEXT,
    parent_id             TEXT,
    node_type             TEXT,
    total_runtime         INTERVAL,
    strategy              TEXT,
    operation             TEXT,
    startup_cost          FLOAT,
    total_cost            FLOAT,
    plan_rows             FLOAT,
    plan_width            INTEGER,
    actual_startup_time   INTERVAL,
    actual_total_time     INTERVAL,
    actual_rows           FLOAT,
    actual_loops          FLOAT,
    parent_relationship   TEXT,
    sort_key              TEXT[],
    sort_method           TEXT[],
    sort_space_used       BIGINT,
    sort_space_type       TEXT,
    join_type             TEXT,
    join_filter           TEXT,
    hash_cond             TEXT,
    relation_name         TEXT,
    alias                 TEXT,
    scan_direction        TEXT,
    index_name            TEXT,
    index_cond            TEXT,
    recheck_cond          TEXT,
    tid_cond              TEXT,
    merge_cond            TEXT,
    subplan_name          TEXT,
    function_name         TEXT,
    function_call         TEXT,
    filter                TEXT,
    one_time_filter       TEXT,
    command               TEXT,
    shared_hit_blocks     BIGINT,
    shared_read_blocks    BIGINT,
    shared_written_blocks BIGINT,
    local_hit_blocks      BIGINT,
    local_read_blocks     BIGINT,
    local_written_blocks  BIGINT,
    temp_read_blocks      BIGINT,
    temp_written_blocks   BIGINT,
    output                TEXT[],
    hash_buckets          BIGINT,
    hash_batches          BIGINT,
    original_hash_batches BIGINT,
    peak_memory_usage     BIGINT,
    schema                TEXT,
    cte_name              TEXT,
    triggers              trigger_plan[]
) LANGUAGE plpgsql AS $$
DECLARE
    plan  xml;
    node  xml;
    xmlns text[] := ARRAY[ARRAY['e', 'http://www.postgresql.org/2009/explain']];
BEGIN
    -- Get the plan.
    EXECUTE 'EXPLAIN (format xml, verbose'
         || CASE WHEN analyzed THEN ', analyze true' ELSE '' END
         || ') ' || query INTO plan;

    IF columns IS NULL THEN
        -- Generate all columns.
        RETURN QUERY SELECT NOW(), * FROM parse_node(
            (xpath('/e:explain/e:Query/e:Plan', plan, xmlns))[1],
            NULL,
            ((xpath('/e:explain/e:Query/e:Total-Runtime/text()', plan, xmlns))[1]::text || ' ms')::interval,
            ARRAY(SELECT p FROM parse_triggers(xpath('/e:explain/e:Query/e:Triggers/e:Trigger', plan, xmlns)) AS p)
        );
    ELSE
        -- Generate only the specified columns.
        RETURN QUERY SELECT CASE WHEN 'planned_at' = ANY(columns) THEN NOW() ELSE NULL END, * FROM parse_node(
            columns,
            (xpath('/e:explain/e:Query/e:Plan', plan, xmlns))[1],
            NULL,
            CASE WHEN 'total_runtime' = ANY(columns) THEN ((xpath('/e:explain/e:Query/e:Total-Runtime/text()', plan, xmlns))[1]::text || ' ms')::interval ELSE NULL END,
            CASE WHEN 'triggers' = ANY(columns) THEN ARRAY(SELECT p FROM parse_triggers(xpath('/e:explain/e:Query/e:Triggers/e:Trigger', plan, xmlns)) AS p) ELSE NULL END
        );
    END IF;
END;
$$;
