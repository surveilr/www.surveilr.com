## surveilr Flexible Graph Usage Example
This pattern shows how to leverage the `flexible_graph_*` tables to represent flexible graph-like 
structures that don't have a strict `uniform_resource` connection. To use this graph structure with 
a `uniform_resource`, please see `uniform_resource_graph_*` tables.

### Commands Used:

1. **Initialize an empty RSSD**: 
   ```bash
   cd ./lib/patter/flexible-graph
   surveilr admin init
   ```

2. **Execute `stateless` and `stateful` statements**
   ```bash
   cat stateful.sql | sqlite3 ./resource-surveillance.sqlite.db # create the tables and insert data
   cat stateless.sql | sqlite3 ./resource-surveillance.sqlite.db # create views to view data
   ```
