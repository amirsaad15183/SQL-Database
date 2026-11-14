-- Destructive: drops project objects and permanently purges their table data.
-- Use only for an intentional development reset; never invoked by setup.sql.
-- Missing objects are tolerated; inspect output for other drop failures.

SET SERVEROUTPUT ON SIZE UNLIMITED;
SET DEFINE OFF;

BEGIN
    EXECUTE IMMEDIATE 'DROP PACKAGE PKG_AMIR_BOOKSTORE';
    DBMS_OUTPUT.PUT_LINE('Dropped package PKG_AMIR_BOOKSTORE.');
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -4043 THEN
            DBMS_OUTPUT.PUT_LINE('Package PKG_AMIR_BOOKSTORE did not exist.');
        ELSE
            DBMS_OUTPUT.PUT_LINE('Unexpected package-drop error: ' || SQLERRM);
        END IF;
END;
/

DECLARE
    TYPE t_name_list IS TABLE OF VARCHAR2(30);
    v_names t_name_list := t_name_list(
        'TRG_AOBS_BOOK_BIU',
        'TRG_AOBS_BOOK_PRICE_AU',
        'TRG_AOBS_ORDER_ITEM_BI',
        'TRG_AOBS_ORDER_ITEM_AI',
        'TRG_AOBS_RETURN_BIU',
        'TRG_AOBS_RETURN_AIU'
    );
BEGIN
    FOR i IN 1 .. v_names.COUNT LOOP
        BEGIN
            EXECUTE IMMEDIATE 'DROP TRIGGER ' || v_names(i);
            DBMS_OUTPUT.PUT_LINE('Dropped trigger ' || v_names(i) || '.');
        EXCEPTION
            WHEN OTHERS THEN
                IF SQLCODE = -4080 THEN
                    DBMS_OUTPUT.PUT_LINE('Trigger ' || v_names(i) || ' did not exist.');
                ELSE
                    DBMS_OUTPUT.PUT_LINE(
                        'Unexpected error dropping ' || v_names(i) || ': ' || SQLERRM
                    );
                END IF;
        END;
    END LOOP;
END;
/

DECLARE
    TYPE t_name_list IS TABLE OF VARCHAR2(30);
    v_names t_name_list := t_name_list(
        'AOBS_PRICE_AUDIT',
        'AOBS_RETURN',
        'AOBS_ORDER_ITEM',
        'AOBS_ORDERS',
        'AOBS_BOOK_AUTHOR',
        'AOBS_BOOK',
        'AOBS_CUSTOMER',
        'AOBS_AUTHOR',
        'AOBS_CATEGORY'
    );
BEGIN
    FOR i IN 1 .. v_names.COUNT LOOP
        BEGIN
            EXECUTE IMMEDIATE
                'DROP TABLE ' || v_names(i) || ' CASCADE CONSTRAINTS PURGE';
            DBMS_OUTPUT.PUT_LINE('Dropped table ' || v_names(i) || '.');
        EXCEPTION
            WHEN OTHERS THEN
                IF SQLCODE = -942 THEN
                    DBMS_OUTPUT.PUT_LINE('Table ' || v_names(i) || ' did not exist.');
                ELSE
                    DBMS_OUTPUT.PUT_LINE(
                        'Unexpected error dropping ' || v_names(i) || ': ' || SQLERRM
                    );
                END IF;
        END;
    END LOOP;
END;
/

DECLARE
    TYPE t_name_list IS TABLE OF VARCHAR2(30);
    v_names t_name_list := t_name_list(
        'SEQ_AOBS_CATEGORY',
        'SEQ_AOBS_AUTHOR',
        'SEQ_AOBS_CUSTOMER',
        'SEQ_AOBS_BOOK',
        'SEQ_AOBS_ORDER',
        'SEQ_AOBS_ORDER_ITEM',
        'SEQ_AOBS_RETURN',
        'SEQ_AOBS_RETURN_AUTH',
        'SEQ_AOBS_PRICE_AUDIT'
    );
BEGIN
    FOR i IN 1 .. v_names.COUNT LOOP
        BEGIN
            EXECUTE IMMEDIATE 'DROP SEQUENCE ' || v_names(i);
            DBMS_OUTPUT.PUT_LINE('Dropped sequence ' || v_names(i) || '.');
        EXCEPTION
            WHEN OTHERS THEN
                IF SQLCODE = -2289 THEN
                    DBMS_OUTPUT.PUT_LINE('Sequence ' || v_names(i) || ' did not exist.');
                ELSE
                    DBMS_OUTPUT.PUT_LINE(
                        'Unexpected error dropping ' || v_names(i) || ': ' || SQLERRM
                    );
                END IF;
        END;
    END LOOP;
END;
/
