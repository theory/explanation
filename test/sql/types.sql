\set ECHO 0
\set QUIET 1
BEGIN;
\pset format unaligned
\t
SET IntervalStyle = 'postgres';
\i sql/explain-table.sql

SELECT pg_typeof(planned_at)            = 'timestamptz'::regtype, 'planned_at'         frOM plan('SELECT 1');
SELECT pg_typeof(node_id)               = 'text'::regtype,    'node_id'               FROM parse_node('<Plan><Node-Type>Aggregate</Node-Type></Plan>');
SELECT pg_typeof(parent_id)             = 'text'::regtype,    'parent_id'             FROM parse_node('<Plan><Node-Type>Aggregate</Node-Type></Plan>');
SELECT pg_typeof(node_type)             = 'text'::regtype,    'node_type'             FROM parse_node('<Plan><Node-Type>Aggregate</Node-Type></Plan>');
SELECT pg_typeof(total_runtime)         = 'interval'::regtype,'total_runtime'         FROM parse_node('<Plan><Node-Type>Aggregate</Node-Type></Plan>'::xml, NULL, '12.2 ms');
SELECT pg_typeof(strategy)              = 'text'::regtype,    'strategy'              FROM parse_node('<Plan><Strategy>Sorted</Strategy></Plan>');
SELECT pg_typeof(operation)             = 'text'::regtype,    'operation'             FROM parse_node('<Plan><Operation>foo</Operation></Plan>');
SELECT pg_typeof(startup_cost)          = 'float'::regtype,   'startup_cost'          FROM parse_node('<Plan><Startup-Cost>258.13</Startup-Cost></Plan>');
SELECT pg_typeof(total_cost)            = 'float'::regtype,   'total_cost'            FROM parse_node('<Plan><Total-Cost>259.13</Total-Cost></Plan>');
SELECT pg_typeof(plan_rows)             = 'float'::regtype,   'plan_rows'             FROM parse_node('<Plan><Plan-Rows>1000</Plan-Rows></Plan>');
SELECT pg_typeof(plan_width)            = 'integer'::regtype, 'plan_width'            FROM parse_node('<Plan><Plan-Width>33</Plan-Width></Plan>');
SELECT pg_typeof(actual_startup_time)   = 'interval'::regtype,'actual_startup_time'   FROM parse_node('<Plan><Actual-Startup-Time>0.121</Actual-Startup-Time></Plan>');
SELECT pg_typeof(actual_total_time)     = 'interval'::regtype,'actual_total_time'     FROM parse_node('<Plan><Actual-Total-Time>0.134</Actual-Total-Time></Plan>');
SELECT pg_typeof(actual_rows)           = 'float'::regtype,   'actual_rows'           FROM parse_node('<Plan><Actual-Rows>2000</Actual-Rows></Plan>');
SELECT pg_typeof(actual_loops)          = 'float'::regtype,   'actual_loops'          FROM parse_node('<Plan><Actual-Loops>20</Actual-Loops></Plan>');
SELECT pg_typeof(parent_relationship)   = 'text'::regtype,    'parent_relationship'   FROM parse_node('<Plan><Parent-Relationship>Outer</Parent-Relationship></Plan>');
SELECT pg_typeof(sort_key)              = 'text[]'::regtype,  'sort_key'              FROM parse_node('<Plan><Sort-Key><Item>d.id</Item><Item>d.name</Item></Sort-Key></Plan>');
SELECT pg_typeof(sort_method)           = 'text[]'::regtype,  'sort_method'           FROM parse_node('<Plan><Sort-Method><Item>this</Item><Item>that</Item></Sort-Method></Plan>');
SELECT pg_typeof(sort_space_used)       = 'bigint'::regtype,  'sort_space_used'       FROM parse_node('<Plan><Sort-Space-Used>3242</Sort-Space-Used></Plan>');
SELECT pg_typeof(sort_space_type)       = 'text'::regtype,    'sort_space_type'       FROM parse_node('<Plan><Sort-Space-Type>whatever</Sort-Space-Type></Plan>');
SELECT pg_typeof(join_type)             = 'text'::regtype,    'join_type'             FROM parse_node('<Plan><Join-Type>nested</Join-Type></Plan>');
SELECT pg_typeof(join_filter)           = 'text'::regtype,    'join_filter'           FROM parse_node('<Plan><Join-Filter>pandering</Join-Filter></Plan>');
SELECT pg_typeof(hash_cond)             = 'text'::regtype,    'hash_cond'             FROM parse_node('<Plan><Hash-Cond>(de.distribution = d.name)</Hash-Cond></Plan>');
SELECT pg_typeof(relation_name)         = 'text'::regtype,    'relation_name'         FROM parse_node('<Plan><Relation-Name>users</Relation-Name></Plan>');
SELECT pg_typeof(alias)                 = 'text'::regtype,    'alias'                 FROM parse_node('<Plan><Alias>u</Alias></Plan>');
SELECT pg_typeof(scan_direction)        = 'text'::regtype,    'scan_direction'        FROM parse_node('<Plan><Scan-Direction>forward</Scan-Direction></Plan>');
SELECT pg_typeof(index_name)            = 'text'::regtype,    'index_name'            FROM parse_node('<Plan><Index-Name>idx_users</Index-Name></Plan>');
SELECT pg_typeof(index_cond)            = 'text'::regtype,    'index_cond'            FROM parse_node('<Plan><Index-Cond>(u.name = mumble)</Index-Cond></Plan>');
SELECT pg_typeof(recheck_cond)          = 'text'::regtype,    'recheck_cond'          FROM parse_node('<Plan><Recheck-Cond>(u.id = fumble)</Recheck-Cond></Plan>');
SELECT pg_typeof(tid_cond)              = 'text'::regtype,    'tid_cond'              FROM parse_node('<Plan><TID-Cond>(t.id = tid)</TID-Cond></Plan>');
SELECT pg_typeof(merge_cond)            = 'text'::regtype,    'merge_cond'            FROM parse_node('<Plan><Merge-Cond>(m.id = mid)</Merge-Cond></Plan>');
SELECT pg_typeof(subplan_name)          = 'text'::regtype,    'subplan_name'          FROM parse_node('<Plan><Subplan-Name>my-subplan</Subplan-Name></Plan>');
SELECT pg_typeof(function_name)         = 'text'::regtype,    'function_name'         FROM parse_node('<Plan><Function-Name>parse_node()</Function-Name></Plan>');
SELECT pg_typeof(function_call)         = 'text'::regtype,    'function_call'         FROM parse_node('<Plan><Function-Call>parse_node(this, that)</Function-Call></Plan>');
SELECT pg_typeof(filter)                = 'text'::regtype,    'filter'                FROM parse_node('<Plan><Filter>x = y</Filter></Plan>');
SELECT pg_typeof(one_time_filter)       = 'text'::regtype,    'one_time_filter'       FROM parse_node('<Plan><One-Time-Filter>one = two</One-Time-Filter></Plan>');
SELECT pg_typeof(command)               = 'text'::regtype,    'command'               FROM parse_node('<Plan><Command>go!</Command></Plan>');
SELECT pg_typeof(shared_hit_blocks)     = 'bigint'::regtype,  'shared_hit_blocks'     FROM parse_node('<Plan><Shared-Hit-Blocks>2000</Shared-Hit-Blocks></Plan>');
SELECT pg_typeof(shared_read_blocks)    = 'bigint'::regtype,  'shared_read_blocks'    FROM parse_node('<Plan><Shared-Read-Blocks>20</Shared-Read-Blocks></Plan>');
SELECT pg_typeof(shared_written_blocks) = 'bigint'::regtype,  'shared_written_blocks' FROM parse_node('<Plan><Shared-Written-Blocks>0</Shared-Written-Blocks></Plan>');
SELECT pg_typeof(local_hit_blocks)      = 'bigint'::regtype,  'local_hit_blocks'      FROM parse_node('<Plan><Local-Hit-Blocks>3453</Local-Hit-Blocks></Plan>');
SELECT pg_typeof(local_read_blocks)     = 'bigint'::regtype,  'local_read_blocks'     FROM parse_node('<Plan><Local-Read-Blocks>234</Local-Read-Blocks></Plan>');
SELECT pg_typeof(local_written_blocks)  = 'bigint'::regtype,  'local_written_blocks'  FROM parse_node('<Plan><Local-Written-Blocks>12</Local-Written-Blocks></Plan>');
SELECT pg_typeof(temp_read_blocks)      = 'bigint'::regtype,  'temp_read_blocks'      FROM parse_node('<Plan><Temp-Read-Blocks>349394934934934</Temp-Read-Blocks></Plan>');
SELECT pg_typeof(temp_written_blocks)   = 'bigint'::regtype,  'temp_written_blocks'   FROM parse_node('<Plan><Temp-Written-Blocks>2323</Temp-Written-Blocks></Plan>');
SELECT pg_typeof(output)                = 'text[]'::regtype,  'output'                FROM parse_node('<Plan><Output><Item>hi</Item><Item>you</Item></Output></Plan>');
SELECT pg_typeof(hash_buckets)          = 'bigint'::regtype,  'hash_buckets'          FROM parse_node('<Plan><Hash-Buckets>42</Hash-Buckets></Plan>');
SELECT pg_typeof(hash_batches)          = 'bigint'::regtype,  'hash_batches'          FROM parse_node('<Plan><Hash-Batches>96</Hash-Batches></Plan>');
SELECT pg_typeof(original_hash_batches) = 'bigint'::regtype,  'original_hash_batches' FROM parse_node('<Plan><Original-Hash-Batches>2</Original-Hash-Batches></Plan>');
SELECT pg_typeof(peak_memory_usage)     = 'bigint'::regtype,  'peak_memory_usage'     FROM parse_node('<Plan><Peak-Memory-Usage>34234823482348</Peak-Memory-Usage></Plan>');
SELECT pg_typeof(schema)                = 'text'::regtype,    'schema'                FROM parse_node('<Plan><Schema>public</Schema></Plan>');
SELECT pg_typeof(cte_name)              = 'text'::regtype,    'cte_name'              FROM parse_node('<Plan><CTE-Name>ralph</CTE-Name></Plan>');
SELECT pg_typeof(triggers)              = 'trigger_plan[]'::regtype, 'triggers'         FROM parse_node('<Plan><CTE-Name>ralph</CTE-Name></Plan>', NULL, NULL, ARRAY[ROW('Harry', 'Melissa', 'users', '00:00:00.000234', 14)::trigger_plan]);

ROLLBACK;
