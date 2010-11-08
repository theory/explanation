\set ECHO 0
\set QUIET 1
BEGIN;
\pset format unaligned
\t
SET IntervalStyle = 'postgres';
\i sql/explain-table.sql

SELECT pg_typeof("Timestamp")             = 'timestamptz'::regtype, 'Timestamp'         FROM plan('SELECT 1');
SELECT pg_typeof("Node ID")               = 'text'::regtype,    'Node ID'               FROM parse_node('<Plan><Node-Type>Aggregate</Node-Type></Plan>');
SELECT pg_typeof("Parent ID")             = 'text'::regtype,    'Parent ID'             FROM parse_node('<Plan><Node-Type>Aggregate</Node-Type></Plan>');
SELECT pg_typeof("Node Type")             = 'text'::regtype,    'Node Type'             FROM parse_node('<Plan><Node-Type>Aggregate</Node-Type></Plan>');
SELECT pg_typeof("Total Runtime")         = 'interval'::regtype,'Total Runtime'         FROM parse_node('<Plan><Node-Type>Aggregate</Node-Type></Plan>', NULL, '12.2 ms');
SELECT pg_typeof("Strategy")              = 'text'::regtype,    'Strategy'              FROM parse_node('<Plan><Strategy>Sorted</Strategy></Plan>');
SELECT pg_typeof("Operation")             = 'text'::regtype,    'Operation'             FROM parse_node('<Plan><Operation>foo</Operation></Plan>');
SELECT pg_typeof("Startup Cost")          = 'float'::regtype,   'Startup Cost'          FROM parse_node('<Plan><Startup-Cost>258.13</Startup-Cost></Plan>');
SELECT pg_typeof("Total Cost")            = 'float'::regtype,   'Total Cost'            FROM parse_node('<Plan><Total-Cost>259.13</Total-Cost></Plan>');
SELECT pg_typeof("Plan Rows")             = 'float'::regtype,   'Plan Rows'             FROM parse_node('<Plan><Plan-Rows>1000</Plan-Rows></Plan>');
SELECT pg_typeof("Plan Width")            = 'integer'::regtype, 'Plan Width'            FROM parse_node('<Plan><Plan-Width>33</Plan-Width></Plan>');
SELECT pg_typeof("Actual Startup Time")   = 'interval'::regtype,'Actual Startup Time'   FROM parse_node('<Plan><Actual-Startup-Time>0.121</Actual-Startup-Time></Plan>');
SELECT pg_typeof("Actual Total Time")     = 'interval'::regtype,'Actual Total Time'     FROM parse_node('<Plan><Actual-Total-Time>0.134</Actual-Total-Time></Plan>');
SELECT pg_typeof("Actual Rows")           = 'float'::regtype,   'Actual Rows'           FROM parse_node('<Plan><Actual-Rows>2000</Actual-Rows></Plan>');
SELECT pg_typeof("Actual Loops")          = 'float'::regtype,   'Actual Loops'          FROM parse_node('<Plan><Actual-Loops>20</Actual-Loops></Plan>');
SELECT pg_typeof("Parent Relationship")   = 'text'::regtype,    'Parent Relationship'   FROM parse_node('<Plan><Parent-Relationship>Outer</Parent-Relationship></Plan>');
SELECT pg_typeof("Sort Key")              = 'text[]'::regtype,  'Sort Key'              FROM parse_node('<Plan><Sort-Key><Item>d.id</Item><Item>d.name</Item></Sort-Key></Plan>');
SELECT pg_typeof("Sort Method")           = 'text[]'::regtype,  'Sort Method'           FROM parse_node('<Plan><Sort-Method><Item>this</Item><Item>that</Item></Sort-Method></Plan>');
SELECT pg_typeof("Sort Space Used")       = 'bigint'::regtype,  'Sort Space Used'       FROM parse_node('<Plan><Sort-Space-Used>3242</Sort-Space-Used></Plan>');
SELECT pg_typeof("Sort Space Type")       = 'text'::regtype,    'Sort Space Type'       FROM parse_node('<Plan><Sort-Space-Type>whatever</Sort-Space-Type></Plan>');
SELECT pg_typeof("Join Type")             = 'text'::regtype,    'Join Type'             FROM parse_node('<Plan><Join-Type>nested</Join-Type></Plan>');
SELECT pg_typeof("Join Filter")           = 'text'::regtype,    'Join Filter'           FROM parse_node('<Plan><Join-Filter>pandering</Join-Filter></Plan>');
SELECT pg_typeof("Hash Cond")             = 'text'::regtype,    'Hash Cond'             FROM parse_node('<Plan><Hash-Cond>(de.distribution = d.name)</Hash-Cond></Plan>');
SELECT pg_typeof("Relation Name")         = 'text'::regtype,    'Relation Name'         FROM parse_node('<Plan><Relation-Name>users</Relation-Name></Plan>');
SELECT pg_typeof("Alias")                 = 'text'::regtype,    'Alias'                 FROM parse_node('<Plan><Alias>u</Alias></Plan>');
SELECT pg_typeof("Scan Direction")        = 'text'::regtype,    'Scan Direction'        FROM parse_node('<Plan><Scan-Direction>forward</Scan-Direction></Plan>');
SELECT pg_typeof("Index Name")            = 'text'::regtype,    'Index Name'            FROM parse_node('<Plan><Index-Name>idx_users</Index-Name></Plan>');
SELECT pg_typeof("Index Cond")            = 'text'::regtype,    'Index Cond'            FROM parse_node('<Plan><Index-Cond>(u.name = mumble)</Index-Cond></Plan>');
SELECT pg_typeof("Recheck Cond")          = 'text'::regtype,    'Recheck Cond'          FROM parse_node('<Plan><Recheck-Cond>(u.id = fumble)</Recheck-Cond></Plan>');
SELECT pg_typeof("TID Cond")              = 'text'::regtype,    'TID Cond'              FROM parse_node('<Plan><TID-Cond>(t.id = tid)</TID-Cond></Plan>');
SELECT pg_typeof("Merge Cond")            = 'text'::regtype,    'Merge Cond'            FROM parse_node('<Plan><Merge-Cond>(m.id = mid)</Merge-Cond></Plan>');
SELECT pg_typeof("Subplan Name")          = 'text'::regtype,    'Subplan Name'          FROM parse_node('<Plan><Subplan-Name>my-subplan</Subplan-Name></Plan>');
SELECT pg_typeof("Function Name")         = 'text'::regtype,    'Function Name'         FROM parse_node('<Plan><Function-Name>parse_node()</Function-Name></Plan>');
SELECT pg_typeof("Function Call")         = 'text'::regtype,    'Function Call'         FROM parse_node('<Plan><Function-Call>parse_node(this, that)</Function-Call></Plan>');
SELECT pg_typeof("Filter")                = 'text'::regtype,    'Filter'                FROM parse_node('<Plan><Filter>x = y</Filter></Plan>');
SELECT pg_typeof("One-Time Filter")       = 'text'::regtype,    'One-Time Filter'       FROM parse_node('<Plan><One-Time-Filter>one = two</One-Time-Filter></Plan>');
SELECT pg_typeof("Command")               = 'text'::regtype,    'Command'               FROM parse_node('<Plan><Command>go!</Command></Plan>');
SELECT pg_typeof("Shared Hit Blocks")     = 'bigint'::regtype,  'Shared Hit Blocks'     FROM parse_node('<Plan><Shared-Hit-Blocks>2000</Shared-Hit-Blocks></Plan>');
SELECT pg_typeof("Shared Read Blocks")    = 'bigint'::regtype,  'Shared Read Blocks'    FROM parse_node('<Plan><Shared-Read-Blocks>20</Shared-Read-Blocks></Plan>');
SELECT pg_typeof("Shared Written Blocks") = 'bigint'::regtype,  'Shared Written Blocks' FROM parse_node('<Plan><Shared-Written-Blocks>0</Shared-Written-Blocks></Plan>');
SELECT pg_typeof("Local Hit Blocks")      = 'bigint'::regtype,  'Local Hit Blocks'      FROM parse_node('<Plan><Local-Hit-Blocks>3453</Local-Hit-Blocks></Plan>');
SELECT pg_typeof("Local Read Blocks")     = 'bigint'::regtype,  'Local Read Blocks'     FROM parse_node('<Plan><Local-Read-Blocks>234</Local-Read-Blocks></Plan>');
SELECT pg_typeof("Local Written Blocks")  = 'bigint'::regtype,  'Local Written Blocks'  FROM parse_node('<Plan><Local-Written-Blocks>12</Local-Written-Blocks></Plan>');
SELECT pg_typeof("Temp Read Blocks")      = 'bigint'::regtype,  'Temp Read Blocks'      FROM parse_node('<Plan><Temp-Read-Blocks>349394934934934</Temp-Read-Blocks></Plan>');
SELECT pg_typeof("Temp Written Blocks")   = 'bigint'::regtype,  'Temp Written Blocks'   FROM parse_node('<Plan><Temp-Written-Blocks>2323</Temp-Written-Blocks></Plan>');
SELECT pg_typeof("Output")                = 'text[]'::regtype,  'Output'                FROM parse_node('<Plan><Output><Item>hi</Item><Item>you</Item></Output></Plan>');
SELECT pg_typeof("Hash Buckets")          = 'bigint'::regtype,  'Hash Buckets'          FROM parse_node('<Plan><Hash-Buckets>42</Hash-Buckets></Plan>');
SELECT pg_typeof("Hash Batches")          = 'bigint'::regtype,  'Hash Batches'          FROM parse_node('<Plan><Hash-Batches>96</Hash-Batches></Plan>');
SELECT pg_typeof("Original Hash Batches") = 'bigint'::regtype,  'Original Hash Batches' FROM parse_node('<Plan><Original-Hash-Batches>2</Original-Hash-Batches></Plan>');
SELECT pg_typeof("Peak Memory Usage")     = 'bigint'::regtype,  'Peak Memory Usage'     FROM parse_node('<Plan><Peak-Memory-Usage>34234823482348</Peak-Memory-Usage></Plan>');
SELECT pg_typeof("Schema")                = 'text'::regtype,    'Schema'                FROM parse_node('<Plan><Schema>public</Schema></Plan>');
SELECT pg_typeof("CTE Name")              = 'text'::regtype,    'CTE Name'              FROM parse_node('<Plan><CTE-Name>ralph</CTE-Name></Plan>');
SELECT pg_typeof("Triggers")              = 'text[]'::regtype,  'Triggers'              FROM parse_node('<Plan><CTE-Name>ralph</CTE-Name></Plan>', NULL, NULL, '{foo}');

ROLLBACK;
