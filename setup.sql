-- Install into an empty schema; dependencies must be created in this order.
-- Oracle DDL commits implicitly; a failed installation may leave partial objects.

SET DEFINE OFF;
SET SERVEROUTPUT ON SIZE UNLIMITED;
WHENEVER OSERROR EXIT FAILURE ROLLBACK;
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK;

@@sql/01_tables.sql
@@sql/02_sequences.sql
@@sql/03_indexes.sql
@@sql/04_package.sql
@@sql/05_triggers.sql

DECLARE
    v_errors NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_errors
    FROM user_errors
    WHERE name = 'PKG_AMIR_BOOKSTORE'
       OR name LIKE 'TRG_AOBS_%';
    IF v_errors > 0 THEN
        RAISE_APPLICATION_ERROR(-20990, 'Compilation errors detected. Inspect USER_ERRORS before loading data.');
    END IF;
END;
/

@@sql/06_seed_data.sql
@@sql/07_validate.sql
