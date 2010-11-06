\set ECHO 0
BEGIN;
\set QUIET 1
\i sql/explain-table.sql
\set QUIET 0

CREATE TABLE foo(id int);

SELECT * FROM plan('select * from foo');
SELECT * FROM plan('select * from foo', true);

SELECT * FROM parse_node($$     <Plan>
       <Node-Type>Aggregate</Node-Type>
       <Strategy>Sorted</Strategy>
       <Startup-Cost>258.13</Startup-Cost>
       <Total-Cost>262.31</Total-Cost>
       <Plan-Rows>4</Plan-Rows>
       <Plan-Width>324</Plan-Width>
       <Actual-Startup-Time>0.121</Actual-Startup-Time>
       <Actual-Total-Time>0.121</Actual-Total-Time>
       <Actual-Rows>0</Actual-Rows>
       <Actual-Loops>1</Actual-Loops>
       <Plans>
         <Plan>
           <Node-Type>Sort</Node-Type>
           <Parent-Relationship>Outer</Parent-Relationship>
           <Startup-Cost>258.13</Startup-Cost>
           <Total-Cost>258.14</Total-Cost>
           <Plan-Rows>4</Plan-Rows>
           <Plan-Width>324</Plan-Width>
           <Actual-Startup-Time>0.117</Actual-Startup-Time>
           <Actual-Total-Time>0.117</Actual-Total-Time>
           <Actual-Rows>0</Actual-Rows>
           <Actual-Loops>1</Actual-Loops>
           <Sort-Key>
             <Item>d.name</Item>
             <Item>d.version</Item>
             <Item>d.abstract</Item>
             <Item>d.description</Item>
             <Item>d.relstatus</Item>
             <Item>d.owner</Item>
             <Item>d.sha1</Item>
             <Item>d.meta</Item>
           </Sort-Key>
           <Sort-Method>quicksort</Sort-Method>
           <Sort-Space-Used>25</Sort-Space-Used>
           <Sort-Space-Type>Memory</Sort-Space-Type>
           <Plans>
             <Plan>
               <Node-Type>Nested Loop</Node-Type>
               <Parent-Relationship>Outer</Parent-Relationship>
               <Join-Type>Left</Join-Type>
               <Startup-Cost>16.75</Startup-Cost>
               <Total-Cost>258.09</Total-Cost>
               <Plan-Rows>4</Plan-Rows>
               <Plan-Width>324</Plan-Width>
               <Actual-Startup-Time>0.009</Actual-Startup-Time>
               <Actual-Total-Time>0.009</Actual-Total-Time>
               <Actual-Rows>0</Actual-Rows>
               <Actual-Loops>1</Actual-Loops>
               <Join-Filter>(semver_cmp(d.version, dt.version) = 0)</Join-Filter>
               <Plans>
                 <Plan>
                   <Node-Type>Hash Join</Node-Type>
                   <Parent-Relationship>Outer</Parent-Relationship>
                   <Join-Type>Inner</Join-Type>
                   <Startup-Cost>16.75</Startup-Cost>
                   <Total-Cost>253.06</Total-Cost>
                   <Plan-Rows>4</Plan-Rows>
                   <Plan-Width>292</Plan-Width>
                   <Actual-Startup-Time>0.009</Actual-Startup-Time>
                   <Actual-Total-Time>0.009</Actual-Total-Time>
                   <Actual-Rows>0</Actual-Rows>
                   <Actual-Loops>1</Actual-Loops>
                   <Hash-Cond>(de.distribution = d.name)</Hash-Cond>
                   <Join-Filter>(semver_cmp(d.version, de.dist_version) = 0)</Join-Filter>↵
                   <Plans>
                     <Plan>
                       <Node-Type>Seq Scan</Node-Type>
                       <Parent-Relationship>Outer</Parent-Relationship>
                       <Relation-Name>distribution_extensions</Relation-Name>
                       <Alias>de</Alias>
                       <Startup-Cost>0.00</Startup-Cost>
                       <Total-Cost>15.10</Total-Cost>
                       <Plan-Rows>510</Plan-Rows>
                       <Plan-Width>128</Plan-Width>
                       <Actual-Startup-Time>0.008</Actual-Startup-Time>
                       <Actual-Total-Time>0.008</Actual-Total-Time>
                       <Actual-Rows>0</Actual-Rows>
                       <Actual-Loops>1</Actual-Loops>
                     </Plan>
                     <Plan>
                       <Node-Type>Hash</Node-Type>
                       <Parent-Relationship>Inner</Parent-Relationship>
                       <Startup-Cost>13.00</Startup-Cost>
                       <Total-Cost>13.00</Total-Cost>
                       <Plan-Rows>300</Plan-Rows>
                       <Plan-Width>228</Plan-Width>
                       <Actual-Startup-Time>0.000</Actual-Startup-Time>
                       <Actual-Total-Time>0.000</Actual-Total-Time>
                       <Actual-Rows>0</Actual-Rows>
                       <Actual-Loops>0</Actual-Loops>
                       <Plans>
                         <Plan>
                           <Node-Type>Seq Scan</Node-Type>
                           <Parent-Relationship>Outer</Parent-Relationship>
                           <Relation-Name>distributions</Relation-Name>
                           <Alias>d</Alias>
                           <Startup-Cost>0.00</Startup-Cost>
                           <Total-Cost>13.00</Total-Cost>
                           <Plan-Rows>300</Plan-Rows>
                           <Plan-Width>228</Plan-Width>
                           <Actual-Startup-Time>0.000</Actual-Startup-Time>
                           <Actual-Total-Time>0.000</Actual-Total-Time>
                           <Actual-Rows>0</Actual-Rows>
                           <Actual-Loops>0</Actual-Loops>
                         </Plan>
                       </Plans>
                     </Plan>
                   </Plans>
                 </Plan>
                 <Plan>
                   <Node-Type>Index Scan</Node-Type>
                   <Parent-Relationship>Inner</Parent-Relationship>
                   <Scan-Direction>NoMovement</Scan-Direction>
                   <Index-Name>distribution_tags_pkey</Index-Name>
                   <Relation-Name>distribution_tags</Relation-Name>
                   <Alias>dt</Alias>
                   <Startup-Cost>0.00</Startup-Cost>
                   <Total-Cost>0.46</Total-Cost>
                   <Plan-Rows>3</Plan-Rows>
                   <Plan-Width>96</Plan-Width>
                   <Actual-Startup-Time>0.000</Actual-Startup-Time>
                   <Actual-Total-Time>0.000</Actual-Total-Time>
                   <Actual-Rows>0</Actual-Rows>
                   <Actual-Loops>0</Actual-Loops>
                   <Index-Cond>(d.name = dt.distribution)</Index-Cond>
                 </Plan>
               </Plans>
             </Plan>
           </Plans>
         </Plan>
         <Plan>
           <Node-Type>Function Scan</Node-Type>
           <Parent-Relationship>SubPlan</Parent-Relationship>
           <Subplan-Name>SubPlan 1</Subplan-Name>
           <Function-Name>unnest</Function-Name>
           <Alias>g</Alias>
           <Startup-Cost>0.00</Startup-Cost>
           <Total-Cost>1.00</Total-Cost>
           <Plan-Rows>100</Plan-Rows>
           <Plan-Width>32</Plan-Width>
           <Actual-Startup-Time>0.000</Actual-Startup-Time>
           <Actual-Total-Time>0.000</Actual-Total-Time>
           <Actual-Rows>0</Actual-Rows>
           <Actual-Loops>0</Actual-Loops>
           <Filter>(x IS NOT NULL)</Filter>
         </Plan>
       </Plans>
     </Plan>
$$);
ROLLBACK;