{% macro get_create_external_table_as_sql(temporary, relation, sql) -%}
  {{ adapter.dispatch('get_create_external_table_as_sql', 'dbt')(temporary, relation, sql) }}
{%- endmacro %}

{% macro default__get_create_external_table_as_sql(temporary, relation, sql) -%}
  {{ return(create_external_table_as(temporary, relation, sql)) }}
{% endmacro %}


{% macro create_external_table_as(temporary, relation, sql) -%}
  {{ adapter.dispatch('create_external_table_as', 'dbt')(temporary, relation, sql) }}
{%- endmacro %}

{% macro default__create_external_table_as(temporary, relation, sql) -%}
  {%- set sql_header = config.get('sql_header', none) -%}

  {{ sql_header if sql_header is not none }}

  create {% if temporary: -%}temporary{%- endif %} table
    {{ relation.include(database=(not temporary), schema=(not temporary)) }}
  as (
    {{ sql }}
  );
{%- endmacro %}

{% macro synapseserverless__create_external_table_as(temporary, relation, sql) -%}
   {%- set location = config.get('location', default="") -%}
   {%- set data_source = config.get('data_source', default="") -%}
   {%- set file_format = config.get('file_format', default="") -%}
   {% set tmp_relation = relation.incorporate(
   path={"identifier": relation.identifier.replace("#", "") ~ '_temp_view'},
   type='view')-%}
   {%- set temp_view_sql = sql.replace("'", "''") -%}

   {{ synapseserverless__drop_relation_script(tmp_relation) }}

   {{ synapseserverless__drop_relation_script(relation) }}

   EXEC('create view {{ tmp_relation.schema }}.{{ tmp_relation.identifier }} as
    {{ temp_view_sql }}
    ');

  CREATE EXTERNAL TABLE {{ relation.include(database=False) }}
    WITH(
      LOCATION = {{ "\'" + location + "\'" }},
      DATA_SOURCE = {{data_source}},
      FILE_FORMAT = {{file_format}}
      )
    AS (SELECT * FROM {{ tmp_relation.schema }}.{{ tmp_relation.identifier }})

   {{ synapseserverless__drop_relation_script(tmp_relation) }}

{% endmacro %}