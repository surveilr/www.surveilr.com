# surveilr_osquery_ms_create_behaviour

## Description
Creates a behavior record which is used as a configuration scheme for `surveilr osquery-ms` nodes.

## Arguments
- `behavior_name`: The name to give the behavior
- `config`: The JSON configuration for the behavior

  
## Returns
- `String`: The behavior ID

## Example
```sql
select surveilr_osquery_ms_create_behaviour('behaviorr_name', '{\"tls_proc\": {\"query\": \"select * from processes\", \"interval\": 60}, \"routes\": {\"query\": \"SELECT * FROM routes WHERE destination = ''::1''\", \"interval\": 60}}');"
```