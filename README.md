# dbt-synapse-serverless

## Installation
```sh
poetry add git+ssh://git@git.taservs.net/pnguyen/dbt-synapse-serverless.git@main
```
## Authentication
Please see the [Authentication section of dbt-sqlserver's README.md](https://github.com/dbt-msft/dbt-sqlserver#authentication).

The only difference is to provide the adapter type as `synapseserverless` so for example:

```yml
jaffle_shop:
  target: serverless
  outputs:
    serverless:
      type: synapseserverless
      driver: "ODBC Driver 17 for SQL Server"
      schema: dbo
      host: <serverlessendpoint>
      database: <serverlessdb>
      authentication: CLI
```
