\set ECHO 0
\set QUIET 1
BEGIN;
\t
\pset format unaligned
\i sql/explain-table.sql

SELECT "Node Type"             FROM parse_node('<Plan><Node-Type>Aggregate</Node-Type></Plan>');
SELECT "Strategy"              FROM parse_node('<Plan><Strategy>Sorted</Strategy></Plan>');
SELECT "Operation"             FROM parse_node('<Plan><Operation>foo</Operation></Plan>');
SELECT "Startup Cost"          FROM parse_node('<Plan><Startup-Cost>258.13</Startup-Cost></Plan>');
SELECT "Total Cost"            FROM parse_node('<Plan><Total-Cost>259.13</Total-Cost></Plan>');
SELECT "Plan Rows"             FROM parse_node('<Plan><Plan-Rows>1000</Plan-Rows></Plan>');
SELECT "Plan Width"            FROM parse_node('<Plan><Plan-Width>33</Plan-Width></Plan>');
SELECT "Actual Startup Time"   FROM parse_node('<Plan><Actual-Startup-Time>0.121</Actual-Startup-Time></Plan>');
SELECT "Actual Total Time"     FROM parse_node('<Plan><Actual-Total-Time>0.134</Actual-Total-Time></Plan>');
SELECT "Actual Rows"           FROM parse_node('<Plan><Actual-Rows>2000</Actual-Rows></Plan>');
SELECT "Actual Loops"          FROM parse_node('<Plan><Actual-Loops>20</Actual-Loops></Plan>');
SELECT "Parent Relationship"   FROM parse_node('<Plan><Parent-Relationship>Outer</Parent-Relationship></Plan>');
SELECT "Sort Key"              FROM parse_node('<Plan><Sort-Key><Item>d.id</Item><Item>d.name</Item></Sort-Key></Plan>');
SELECT "Sort Method"           FROM parse_node('<Plan><Sort-Method><Item>this</Item><Item>that</Item></Sort-Method></Plan>');
SELECT "Sort Space Type"       FROM parse_node('<Plan><Sort-Space-Type>whatever</Sort-Space-Type></Plan>');
SELECT "Join Type"             FROM parse_node('<Plan><Join-Type>nested</Join-Type></Plan>');
SELECT "Join Filter"           FROM parse_node('<Plan><Join-Filter>pandering</Join-Filter></Plan>');
SELECT "Hash Cond"             FROM parse_node('<Plan><Hash-Cond>(de.distribution = d.name)</Hash-Cond></Plan>');
SELECT "Relation Name"         FROM parse_node('<Plan><Relation-Name>users</Relation-Name></Plan>');
SELECT "Alias"                 FROM parse_node('<Plan><Alias>u</Alias></Plan>');
SELECT "Scan Direction"        FROM parse_node('<Plan><Scan-Direction>forward</Scan-Direction></Plan>');
SELECT "Index Name"            FROM parse_node('<Plan><Index-Name>idx_users</Index-Name></Plan>');
SELECT "Index Cond"            FROM parse_node('<Plan><Index-Cond>(u.name = mumble)</Index-Cond></Plan>');
SELECT "Recheck Cond"          FROM parse_node('<Plan><Recheck-Cond>(u.id = fumble)</Recheck-Cond></Plan>');
SELECT "TID Cond"              FROM parse_node('<Plan><TID-Cond>(t.id = tid)</TID-Cond></Plan>');
SELECT "Merge Cond"            FROM parse_node('<Plan><Merge-Cond>(m.id = mid)</Merge-Cond></Plan>');
SELECT "Subplan Name"          FROM parse_node('<Plan><Subplan-Name>my-subplan</Subplan-Name></Plan>');
SELECT "Function Name"         FROM parse_node('<Plan><Function-Name>parse_node()</Function-Name></Plan>');
SELECT "Function Call"         FROM parse_node('<Plan><Function-Call>parse_node(this, that)</Function-Call></Plan>');
SELECT "Filter"                FROM parse_node('<Plan><Filter>x = y</Filter></Plan>');
SELECT "One-Time Filter"       FROM parse_node('<Plan><One-Time-Filter>one = two</One-Time-Filter></Plan>');
SELECT "Command"               FROM parse_node('<Plan><Command>go!</Command></Plan>');
SELECT "Shared Hit Blocks"     FROM parse_node('<Plan><Shared-Hit-Blocks>2000</Shared-Hit-Blocks></Plan>');
SELECT "Shared Read Blocks"    FROM parse_node('<Plan><Shared-Read-Blocks>20</Shared-Read-Blocks></Plan>');
SELECT "Shared Written Blocks" FROM parse_node('<Plan><Shared-Written-Blocks>0</Shared-Written-Blocks></Plan>');
SELECT "Local Hit Blocks"      FROM parse_node('<Plan><Local-Hit-Blocks>3453</Local-Hit-Blocks></Plan>');
SELECT "Local Read Blocks"     FROM parse_node('<Plan><Local-Read-Blocks>234</Local-Read-Blocks></Plan>');
SELECT "Local Written Blocks"  FROM parse_node('<Plan><Local-Written-Blocks>12</Local-Written-Blocks></Plan>');
SELECT "Temp Read Blocks"      FROM parse_node('<Plan><Temp-Read-Blocks>349394934934934</Temp-Read-Blocks></Plan>');
SELECT "Temp Written Blocks"   FROM parse_node('<Plan><Temp-Written-Blocks>2323</Temp-Written-Blocks></Plan>');
SELECT "Output"                FROM parse_node('<Plan><Output><Item>hi</Item><Item>you</Item></Output></Plan>');
SELECT "Hash Buckets"          FROM parse_node('<Plan><Hash-Buckets>42</Hash-Buckets></Plan>');
SELECT "Hash Batches"          FROM parse_node('<Plan><Hash-Batches>96</Hash-Batches></Plan>');
SELECT "Original Hash Batches" FROM parse_node('<Plan><Original-Hash-Batches>2</Original-Hash-Batches></Plan>');
SELECT "Peak Memory Usage"     FROM parse_node('<Plan><Peak-Memory-Usage>34234823482348</Peak-Memory-Usage></Plan>');
SELECT "Schema"                FROM parse_node('<Plan><Schema>public</Schema></Plan>');
SELECT "CTE Name"              FROM parse_node('<Plan><CTE-Name>ralph</CTE-Name></Plan>');

ROLLBACK;
