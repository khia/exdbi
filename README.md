exdbi
=====

Elixir Database Interface abstraction layer with plugable backends

What does it do
---------------

It deals with formatting queries towards DB.

How does it work
----------------

  * every function in API receives db handler as first argument
  * it binds values to keys in heredoc
  * it replaces references written as :{...} in a query with binded values
  * it calls query(db_handler, statement, bindings) of DBI backend

How to use it
-------------

    bar = "bar_value"
    DBI.query!(db_handler, """, foo: 1, bar: bar, table: "test")
        SELECT *, :{bar} FROM :{test} WHERE foo = :{foo}
    """

API
---

  * query
  * query!
  * query_stream! - return results of the query as an elixir stream

How to write your own backend
-----------------------------

    defimpl DBI, for: DBI.PostgreSQL do
        use DBI.Implementation

        def query(db_handler, statement, bindings) do
          parsed_statement = DBI.Statement.parse(statement)
          # execute query
        end
    end

