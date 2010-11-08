\set ECHO 0
\set QUIET 1
BEGIN;
\t
\pset format unaligned
SET IntervalStyle = 'postgres';
\i sql/explain-table.sql

SELECT node_type             FROM parse_node('<Plan><Node-Type>Aggregate</Node-Type></Plan>');
SELECT strategy              FROM parse_node('<Plan><Strategy>Sorted</Strategy></Plan>');
SELECT operation             FROM parse_node('<Plan><Operation>foo</Operation></Plan>');
SELECT startup_cost          FROM parse_node('<Plan><Startup-Cost>258.13</Startup-Cost></Plan>');
SELECT total_cost            FROM parse_node('<Plan><Total-Cost>259.13</Total-Cost></Plan>');
SELECT plan_rows             FROM parse_node('<Plan><Plan-Rows>1000</Plan-Rows></Plan>');
SELECT plan_width            FROM parse_node('<Plan><Plan-Width>33</Plan-Width></Plan>');
SELECT actual_startup_time   FROM parse_node('<Plan><Actual-Startup-Time>0.121</Actual-Startup-Time></Plan>');
SELECT actual_total_time     FROM parse_node('<Plan><Actual-Total-Time>0.134</Actual-Total-Time></Plan>');
SELECT actual_rows           FROM parse_node('<Plan><Actual-Rows>2000</Actual-Rows></Plan>');
SELECT actual_loops          FROM parse_node('<Plan><Actual-Loops>20</Actual-Loops></Plan>');
SELECT parent_relationship   FROM parse_node('<Plan><Parent-Relationship>Outer</Parent-Relationship></Plan>');
SELECT sort_key              FROM parse_node('<Plan><Sort-Key><Item>d.id</Item><Item>d.name</Item></Sort-Key></Plan>');
SELECT sort_method           FROM parse_node('<Plan><Sort-Method><Item>this</Item><Item>that</Item></Sort-Method></Plan>');
SELECT sort_space_type       FROM parse_node('<Plan><Sort-Space-Type>whatever</Sort-Space-Type></Plan>');
SELECT sort_space_used       FROM parse_node('<Plan><Sort-Space-Used>32434</Sort-Space-Used></Plan>');
SELECT join_type             FROM parse_node('<Plan><Join-Type>nested</Join-Type></Plan>');
SELECT join_filter           FROM parse_node('<Plan><Join-Filter>pandering</Join-Filter></Plan>');
SELECT hash_cond             FROM parse_node('<Plan><Hash-Cond>(de.distribution = d.name)</Hash-Cond></Plan>');
SELECT relation_name         FROM parse_node('<Plan><Relation-Name>users</Relation-Name></Plan>');
SELECT alias                 FROM parse_node('<Plan><Alias>u</Alias></Plan>');
SELECT scan_direction        FROM parse_node('<Plan><Scan-Direction>forward</Scan-Direction></Plan>');
SELECT index_name            FROM parse_node('<Plan><Index-Name>idx_users</Index-Name></Plan>');
SELECT index_cond            FROM parse_node('<Plan><Index-Cond>(u.name = mumble)</Index-Cond></Plan>');
SELECT recheck_cond          FROM parse_node('<Plan><Recheck-Cond>(u.id = fumble)</Recheck-Cond></Plan>');
SELECT tid_cond              FROM parse_node('<Plan><TID-Cond>(t.id = tid)</TID-Cond></Plan>');
SELECT merge_cond            FROM parse_node('<Plan><Merge-Cond>(m.id = mid)</Merge-Cond></Plan>');
SELECT subplan_name          FROM parse_node('<Plan><Subplan-Name>my-subplan</Subplan-Name></Plan>');
SELECT function_name         FROM parse_node('<Plan><Function-Name>parse_node()</Function-Name></Plan>');
SELECT function_call         FROM parse_node('<Plan><Function-Call>parse_node(this, that)</Function-Call></Plan>');
SELECT filter                FROM parse_node('<Plan><Filter>x = y</Filter></Plan>');
SELECT one_time_filter       FROM parse_node('<Plan><One-Time-Filter>one = two</One-Time-Filter></Plan>');
SELECT command               FROM parse_node('<Plan><Command>go!</Command></Plan>');
SELECT shared_hit_blocks     FROM parse_node('<Plan><Shared-Hit-Blocks>2000</Shared-Hit-Blocks></Plan>');
SELECT shared_read_blocks    FROM parse_node('<Plan><Shared-Read-Blocks>20</Shared-Read-Blocks></Plan>');
SELECT shared_written_blocks FROM parse_node('<Plan><Shared-Written-Blocks>0</Shared-Written-Blocks></Plan>');
SELECT local_hit_blocks      FROM parse_node('<Plan><Local-Hit-Blocks>3453</Local-Hit-Blocks></Plan>');
SELECT local_read_blocks     FROM parse_node('<Plan><Local-Read-Blocks>234</Local-Read-Blocks></Plan>');
SELECT local_written_blocks  FROM parse_node('<Plan><Local-Written-Blocks>12</Local-Written-Blocks></Plan>');
SELECT temp_read_blocks      FROM parse_node('<Plan><Temp-Read-Blocks>349394934934934</Temp-Read-Blocks></Plan>');
SELECT temp_written_blocks   FROM parse_node('<Plan><Temp-Written-Blocks>2323</Temp-Written-Blocks></Plan>');
SELECT output                FROM parse_node('<Plan><Output><Item>hi</Item><Item>you</Item></Output></Plan>');
SELECT hash_buckets          FROM parse_node('<Plan><Hash-Buckets>42</Hash-Buckets></Plan>');
SELECT hash_batches          FROM parse_node('<Plan><Hash-Batches>96</Hash-Batches></Plan>');
SELECT original_hash_batches FROM parse_node('<Plan><Original-Hash-Batches>2</Original-Hash-Batches></Plan>');
SELECT peak_memory_usage     FROM parse_node('<Plan><Peak-Memory-Usage>34234823482348</Peak-Memory-Usage></Plan>');
SELECT schema                FROM parse_node('<Plan><Schema>public</Schema></Plan>');
SELECT cte_name              FROM parse_node('<Plan><CTE-Name>ralph</CTE-Name></Plan>');

ROLLBACK;
