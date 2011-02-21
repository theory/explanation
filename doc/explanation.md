explanation 0.3.0
=================

This extension adds a new function, `explanation()`, to your database. Pass it
a string that executes a query and the function runs `EXPLAIN` on the query
and returns the results as a table. Each node in the plan is represented by a
single row, and child nodes refer to the unique identifier of their parents.
The results, that is, are organized into a proximity tree.

Synopsis
--------

Plan a simple query:

    SELECT node_type, strategy, actual_startup_time, actual_total_time
      FROM explanation(
           query    := $$ SELECT * FROM pg_class WHERE relname = 'users' $$,
           analyzed := true
      );

Output:

     node_type  │ strategy │ actual_startup_time │ actual_total_time 
    ────────────┼──────────┼─────────────────────┼───────────────────
     Index Scan │          │ 00:00:00.000017     │ 00:00:00.000017

Usage
-----

To use the `explanation()` function, simply pass a string you'd like to have
`EXPLAIN`ed:

    SELECT * FROM explanation(:query);

If you'd like the output of `EXPLAIN ANALYZE`, pass `true` as the second
argument:

    SELECT * FROM explanation(:query, true);

Or via the `analyzed` parameter:

    SELECT * FROM explanation(query := :query, anayzed := true);

The function returns a relation with each node of the plan as a single row.
The first row will be the outermost node, and any other rows represent the
child nodes. The structure of the relation is the same as this `CREATE TABLE`
statement, which you can use to actually insert values:

    CREATE TABLE plans (
        planned_at              TIMESTAMPTZ,
        node_id                 TEXT PRIMARY KEY,
        parent_id               TEXT REFERENCES plans(node_id),
        node_type               TEXT NOT NULL,
        total_runtime           INTERVAL,
        strategy                TEXT,
        operation               TEXT,
        startup_cost            FLOAT,
        total_cost              FLOAT,
        plan_rows               FLOAT,
        plan_width              INTEGER,
        actual_startup_time     INTERVAL,
        actual_total_time       INTERVAL,
        actual_rows             FLOAT,
        actual_loops            FLOAT,
        parent_relationship     TEXT,
        sort_key                TEXT[],
        sort_method             TEXT[],
        sort_space_used         BIGINT,
        sort_space_type         TEXT,
        join_type               TEXT,
        join_filter             TEXT,
        hash_cond               TEXT,
        relation_name           TEXT,
        alias                   TEXT,
        scan_direction          TEXT,
        index_name              TEXT,
        index_cond              TEXT,
        recheck_cond            TEXT,
        tid_cond                TEXT,
        merge_cond              TEXT,
        subplan_name            TEXT,
        function_name           TEXT,
        function_call           TEXT,
        filter                  TEXT,
        one_time_filter         TEXT,
        command                 TEXT,
        shared_hit_blocks       BIGINT,
        shared_read_blocks      BIGINT,
        shared_written_blocks   BIGINT,
        local_hit_blocks        BIGINT,
        local_read_blocks       BIGINT,
        local_written_blocks    BIGINT,
        temp_read_blocks        BIGINT,
        temp_written_blocks     BIGINT,
        output                  TEXT[],
        hash_buckets            BIGINT,
        hash_batches            BIGINT,
        original_hash_batches   BIGINT,
        peak_memory_usage       BIGINT,
        schema                  TEXT,
        cte_name                TEXT,       
        triggers                trigger_plan[]
    );

Insert values like so:

    INSERT INTO plans SELECT * FROM explanation(
        query    := $$ SELECT * FROM pg_class WHERE relname = 'users' $$,
        analyzed := true
    );

Some notes on the columns:

* The `planned_at` column is just `NOW()`. Convenient for when the output is
  stored in a table and you'd like to refer back to earlier plans when
  comparing changes to queries over time.

* The `node_id` column contains an MD5 hash created just before a node is
  parsed, from the concatenation of the server PID and the current time:

      md5( pg_backend_pid() || clock_timestamp() )

  As such it should be adequately unique on a single server. The `parent_id`
  will be `NULL` for the outer plan. For example, here's the output of the
  first three columns of a query with nine plan nodes:

                  node_id              │            parent_id             │   node_type
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

* The `total_runtime` column sums the runtime of the entire query.

* The `triggers` column also applies only to the outer-most plan, and provides
  an array of `trigger_plan` records for the that were called. The columns of
  the composite `trigger_plan` type are:

    + `trigger_name`    TEXT
    + `constraint_name` TEXT
    + `relation`        TEXT
    + `time`            INTERVAL
    + `calls`           FLOAT

  You can turn them into a full table expression by selecting them from the
  `plans` table described above like so:

      SELECT (a.b).trigger_name, (a.b).relation, (a.b).relation,
             (a.b).time, (a.b).calls
        FROM (SELECT unnest(triggers) FROM plans) AS a(b);

All other columns are derived directly from the XML output of `EXPLAIN`.
Please see ["Using
EXPLAIN"](http://www.postgresql.org/docs/current/static/using-explain.html)
for further reading on using `EXPLAIN`.

Specifying Columns
------------------

The column values are created by executing `xpath()` queries against the XML
`EXPLAIN` format. There's a lot of data, so for big queries with lots of
nodes, all those calculations can be quite expensive. For ad hoc analyses this
isn't a big deal, and for slow queries most of the overhead is likely to be
taken up if you analyze. However, if you need to process a lot of queries with
this function, and you don't need all of the data, tell it the data you *do*
want by passing an array listing the columns you're interested in, like so:

    SELECT node_type, strategy, actual_startup_time, actual_total_time
      FROM explanation(
           query    := $$ SELECT * FROM pg_class WHERE relname = 'users' $$,
           analyzed := true,
           columns  := ARRAY['node_type', 'total_runtime', 'strategy', 'total_cost']
      );

With this execution, only the `node_id` (which is always calculated),
`node_type`, `total_runtime`, `strategy`, and `total_cost` columns will
contain values. All others will be `NULL`.

Example
-------

Say you had a table full of queries extracted from a query log, and you'd like
to analyze the sequence, index, function, and tid scans executed against a set
of partitions. You might do something like this to generate that data:

    CREATE TABLE partition_query_stats (
        statement        TEXT     NOT NULL,
        runtime          INTERVAL NOT NULL,
        index_scan_count INT      NOT NULL DEFAULT 0,
        seq_scan_count   INT      NOT NULL DEFAULT 0,
        scan_time        INTERVAL NOT NULL DEFAULT '0 secs'
    );

    CREATE OR REPLACE FUNCTION analyze_partition_queries(
        partition_regex TEXT
    ) RETURNS VOID LANGUAGE plpgsql AS $$
    DECLARE
        query TEXT;
    BEGIN
        FOR query in SELECT query FROM logged_queries LOOP
            INSERT INTO partition_query_stats (
                   statement, runtime, index_scan_count, seq_scan_count,
                  scan_time
            )
            SELECT query,
                   MAX(total_runtime),
                   COUNT( CASE WHEN node_type ~* '.*Index Scan' THEN 1 ELSE NULL END ),
                   COUNT( CASE WHEN node_type IN ('Seq Scan', 'Function Scan', 'Tid Scan') THEN 1 ELSE NULL END ),
                   SUM(actual_total_time )
             FROM explanation(
                  query    := query,
                  analyzed := TRUE, 
                  columns  := ARRAY['total_runtime', 'node_type', 'actual_total_time', 'relation_name']
             )
            WHERE relation_name ~* partition_regex
              AND (node_type LIKE '% Scan' OR node_type = 'Append')
            GROUP BY statement;
        END LOOP;
    END;
    $$;

    SELECT analyze_partition_queries('at_call_log_.+');
    
The scan data would then be in the `query_partition_stats` table for further
examination and analysis.

Author
------

[David E. Wheeler](http://www.justatheory.com/),
[PostgreSQL Experts, Inc.](http://www.pgexperts.com).

Copyright and License
---------------------

Copyright (c) 2010-2011, Marchex.

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