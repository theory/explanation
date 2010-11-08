explain-table 0.1.0
===================

This extension adds a new function, `plan()`, to your database. Pass it a
string that executes a query and the function runs `EXPLAIN` on the query and
returns the results as a table. Each node in the plan is represented by a
single row, and child nodes refer to the unique identifier of their parents.

Synopsis
--------

Plan a simple query:

    SELECT "Node Type", "Strategy",  "Actual Startup Time",
           "Actual Total Time"
      FROM plan(
               $$ SELECT * FROM pg_class WHERE relname = 'users' $$,
               true
           );

Output:

     Node Type  │ Strategy │ Actual Startup Time │ Actual Total Time 
    ────────────┼──────────┼─────────────────────┼───────────────────
     Index Scan │          │ 00:00:00.000017     │ 00:00:00.000017
    

Installation
------------

To build it, just do this:

    make
    make installcheck
    make install

If you encounter an error such as:

    "Makefile", line 8: Need an operator

You need to use GNU make, which may well be installed on your system as
`gmake`:

    gmake
    gmake install
    gmake installcheck

If you encounter an error such as:

    make: pg_config: Command not found

Be sure that you have `pg_config` installed and in your path. If you used a
package management system such as RPM to install PostgreSQL, be sure that the
`-devel` package is also installed. If necessary tell the build process where
to find it:

    env PG_CONFIG=/path/to/pg_config make && make installcheck && make install

And finally, if all that fails (and if you're on PostgreSQL 8.1 or lower, it
likely will), copy the entire distribution directory to the `contrib/`
subdirectory of the PostgreSQL source tree and try it there without
`pg_config`:

    env NO_PGXS=1 make && make installcheck && make install

If you encounter an error such as:

    ERROR:  must be owner of database regression

You need to run the test suite using a super user, such as the default
"postgres" super user:

    make installcheck PGUSER=postgres

Usage
-----

To use the `plan()` function, simply pass a string you'd like to have
`EXPLAIN`ed:

    SELECT * FROM plan(:query);

If you'd like the output of `EXPLAIN ANALYZE`, pass `true` as the
second argument.

    SELECT * FROM plan(:query, true);

The function returns a relation with each node of the plan as a single row.
The first row will be the outermost node, and any other rows represent the
child nodes. The structure of the relation is the same as this `CREATE TABLE`
statement, which you can use to actually insert values:

    CREATE TEMPORARY TABLE plans (
        "Timestamp"             TIMESTAMPTZ,
        "Node ID"               TEXT PRIMARY KEY,
        "Parent ID"             TEXT REFERENCES plans("Node ID"),
        "Node Type"             TEXT NOT NULL,
        "Total Runtime"         INTERVAL,
        "Strategy"              TEXT,
        "Operation"             TEXT,
        "Startup Cost"          FLOAT,
        "Total Cost"            FLOAT,
        "Plan Rows"             FLOAT,
        "Plan Width"            INTEGER,
        "Actual Startup Time"   INTERVAL,
        "Actual Total Time"     INTERVAL,
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
        "CTE Name"              TEXT,       
        "Triggers"              TEXT[]
    );

Some notes on the columns:

* The `"Timestamp"` column is just `NOW()`. Convenient for when the output is
  stored in a table and you'd like to refer back to earlier plans when
  comparing changes to queries over time.

* The `"Node ID"` column contains an MD5 hash created just before a node is
  parsed, from the concatenation of the server PID and the current time:

      md5( pg_backend_pid() || clock_timestamp() )

  As such it should be adequately unique on a single server. The `"Parent ID"`
  will be `NULL` for the outer plan. For example, here's the output of the
  first three columns of a query with nine plan nodes:

                  Node ID              │            Parent ID             │   Node Type
      ─────────────────────────────────┼──────────────────────────────────┼────────────────
      029dde3a3c872f0c960f03d2ecfaf5ee |                                  | Aggregate
      3e4c4968cee7653037613c234a953be1 | 029dde3a3c872f0c960f03d2ecfaf5ee | Sort
      dd3d1b1fb6c70be827075e01b306250c | 3e4c4968cee7653037613c234a953be1 | Nested Loop
      037a8fe70739ed1be6a3006d0ab80c82 | dd3d1b1fb6c70be827075e01b306250c | Hash Join
      2c4e922dc19ce9f01a3bf08fbd76b041 | 037a8fe70739ed1be6a3006d0ab80c82 | Seq Scan
      709b2febd8e560dd8830f4c7277c3758 | 037a8fe70739ed1be6a3006d0ab80c82 | Hash
      9dd89be09ea07a1000a21cbfc09121c7 | 709b2febd8e560dd8830f4c7277c3758 | Seq Scan
      8dc3d35ab978f6c6e46f7927e7b86d21 | dd3d1b1fb6c70be827075e01b306250c | Index Scan
      3d7c72f13ae7571da70f434b5bc9e0af | 029dde3a3c872f0c960f03d2ecfaf5ee | Function Scan

* The `"Total Runtime"` column applies only to the outer-most plan, and sums
  the runtime of the entire query.

* The `"Triggers"` column also applies only to the outer-most plan, and simply
  provides an array of the names of the triggers that were called.

All other columns are derived directly from the XML output of `EXPLAIN`.
Please see ["Using
EXPLAIN"](http://www.postgresql.org/docs/current/static/using-explain.html)
for further reading on using `EXPLAIN`.

Examples
--------

TBD.

Dependencies
------------
The `extension-table` extension requires PostgreSQL 9.0 or higher.

Author
------

[David E. Wheeler](http://justatheory.com/)

Copyright and License
---------------------

Copyright (c) 2010, Marchex.

All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this
  list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright notice,
  this list of conditions and the following disclaimer in the documentation
  and/or other materials provided with the distribution.
 * Neither the name of the Marchex nor the names of its contributors may be
   used to endorse or promote products derived from this software without
   specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.