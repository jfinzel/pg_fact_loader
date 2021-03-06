\set v `echo ${FROMVERSION:-1.3}`
SET client_min_messages TO warning;
--This is for testing functionality of timezone-specific timestamps
SET TIMEZONE TO 'America/Chicago';


DROP TABLE IF EXISTS ft;
CREATE TEMP TABLE ft AS
SELECT fact_table_id, fact_table_relid 
FROM fact_loader.fact_tables;

DROP TABLE IF EXISTS ftrl;
CREATE TEMP TABLE ftrl AS
SELECT fact_table_refresh_log_id, fact_table_id, messages 
FROM fact_loader.fact_table_refresh_logs;

DROP EXTENSION pg_fact_loader CASCADE;
CREATE EXTENSION pg_fact_loader VERSION '1.2';

INSERT INTO fact_loader.fact_tables (fact_table_id, fact_table_relid)
SELECT fact_table_id, fact_table_relid FROM ft WHERE ft.fact_table_id IN
(SELECT fact_table_id FROM ftrl);

INSERT INTO fact_loader.fact_table_refresh_logs (fact_table_refresh_log_id, fact_table_id, messages)
SELECT fact_table_refresh_log_id, fact_table_id, messages FROM ftrl;

UPDATE fact_loader.fact_table_refresh_logs SET messages = 'operator does not exist: integer = jsonb' WHERE messages IS NOT NULL;

SELECT messages FROM fact_loader.fact_table_refresh_logs WHERE messages IS NOT NULL;

ALTER EXTENSION pg_fact_loader UPDATE;

SELECT messages FROM fact_loader.fact_table_refresh_logs WHERE messages IS NOT NULL;
