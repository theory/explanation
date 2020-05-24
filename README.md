explanation 0.3.0
=================

This extension adds a new function, `explanation()`, to your database. Pass it
a string that executes a query and the function runs `EXPLAIN` on the query
and returns the results as a table. Each node in the plan is represented by a
single row, and child nodes refer to the unique identifier of their parents.
The results, that is, are organized into a proximity tree.

[![PGXN version](https://badge.fury.io/pg/explanation.svg)](https://badge.fury.io/pg/explanation)
[![Build Status](https://github.com/theory/explanation/workflows/CI/badge.svg)](https://github.com/theory/explanation/actions)

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
    gmake installcheck
    gmake install

If you encounter an error such as:

    make: pg_config: Command not found

Be sure that you have `pg_config` installed and in your path. If you used a
package management system such as RPM to install PostgreSQL, be sure that the
`-devel` package is also installed. If necessary tell the build process where
to find it:

    env PG_CONFIG=/path/to/pg_config make && make installcheck && make install

If you encounter an error such as:

    ERROR:  must be owner of database regression

You need to run the test suite using a super user, such as the default
"postgres" super user:

    make installcheck PGUSER=postgres

Once `explanation` is installed, you can add it to a database. If you're
running PostgreSQL 9.1.0 or greater, it's a simple as connecting to a database
as a super user and running:

    CREATE EXTENSION explanation;

If you've upgraded your cluster to PostgreSQL 9.1 and already had
`explanation` installed, you can upgrade it to a properly packaged extension
with:

    CREATE EXTENSION explanation FROM unpackaged;

For versions of PostgreSQL less than 9.1.0, you'll need to run the
installation script:

    psql -d mydb -f /path/to/pgsql/share/contrib/explanation.sql

If you want to install `explanation` and all of its supporting objects into a
specific schema, use the `PGOPTIONS` environment variable to specify the
schema, like so:

    PGOPTIONS=--search_path=extensions psql -d mydb -f explanation.sql

Dependencies
------------
The `explanation` extension requires PostgreSQL 9.0 or higher compiled with
XML support (`--with-xml`).

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
