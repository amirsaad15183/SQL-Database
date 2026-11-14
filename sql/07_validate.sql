-- Read-only diagnostics: inspect results; these queries do not raise assertion failures.
-- Seeded installs should meet the row thresholds and have no compilation errors.

SET SERVEROUTPUT ON SIZE UNLIMITED;
SET DEFINE OFF;
SET LINESIZE 240;
SET PAGESIZE 200;

ALTER SESSION SET NLS_DATE_FORMAT = 'YYYY-MM-DD';

SELECT 'AOBS_CATEGORY' AS table_name, COUNT(*) AS actual_rows, 5 AS expected_minimum
FROM AOBS_CATEGORY
UNION ALL
SELECT 'AOBS_AUTHOR', COUNT(*), 5 FROM AOBS_AUTHOR
UNION ALL
SELECT 'AOBS_CUSTOMER', COUNT(*), 10 FROM AOBS_CUSTOMER
UNION ALL
SELECT 'AOBS_BOOK', COUNT(*), 10 FROM AOBS_BOOK
UNION ALL
SELECT 'AOBS_BOOK_AUTHOR', COUNT(*), 10 FROM AOBS_BOOK_AUTHOR
UNION ALL
SELECT 'AOBS_ORDERS', COUNT(*), 10 FROM AOBS_ORDERS
UNION ALL
SELECT 'AOBS_ORDER_ITEM', COUNT(*), 10 FROM AOBS_ORDER_ITEM
UNION ALL
SELECT 'AOBS_RETURN', COUNT(*), 10 FROM AOBS_RETURN
UNION ALL
SELECT 'AOBS_PRICE_AUDIT', COUNT(*), 10 FROM AOBS_PRICE_AUDIT
ORDER BY 1;

SELECT object_type,
       object_name,
       status
FROM user_objects
WHERE object_name LIKE 'AOBS_%'
   OR object_name LIKE 'SEQ_AOBS_%'
   OR object_name LIKE 'IDX_AOBS_%'
   OR object_name LIKE 'TRG_AOBS_%'
   OR object_name = 'PKG_AMIR_BOOKSTORE'
ORDER BY object_type, object_name;

SELECT name,
       type,
       line,
       position,
       text
FROM user_errors
WHERE name = 'PKG_AMIR_BOOKSTORE'
   OR name LIKE 'TRG_AOBS_%'
ORDER BY name, sequence;

SELECT table_name,
       constraint_name,
       constraint_type,
       status
FROM user_constraints
WHERE table_name LIKE 'AOBS_%'
ORDER BY table_name, constraint_type, constraint_name;

SELECT index_name,
       table_name,
       uniqueness,
       status
FROM user_indexes
WHERE table_name LIKE 'AOBS_%'
ORDER BY table_name, index_name;

SELECT book_id,
       title,
       list_price,
       stock_qty
FROM AOBS_BOOK
WHERE UPPER(title) LIKE '%DATABASE%'
ORDER BY title;

SELECT b.book_id,
       b.title,
       a.first_name || ' ' || a.last_name AS author_name
FROM AOBS_BOOK b
JOIN AOBS_BOOK_AUTHOR ba
  ON ba.book_id = b.book_id
JOIN AOBS_AUTHOR a
  ON a.author_id = ba.author_id
WHERE UPPER(a.last_name) = UPPER('Chen')
ORDER BY b.title;

SELECT o.order_id,
       o.total_amount AS stored_total,
       NVL(SUM(oi.line_total), 0) AS calculated_total,
       o.total_amount - NVL(SUM(oi.line_total), 0) AS difference
FROM AOBS_ORDERS o
LEFT JOIN AOBS_ORDER_ITEM oi
  ON oi.order_id = o.order_id
GROUP BY o.order_id, o.total_amount
ORDER BY o.order_id;

SELECT book_id,
       title,
       stock_qty,
       reorder_level,
       CASE
           WHEN stock_qty <= reorder_level THEN 'REORDER'
           ELSE 'SUFFICIENT'
       END AS inventory_status
FROM AOBS_BOOK
ORDER BY inventory_status DESC, stock_qty;

SELECT a.audit_id,
       b.title,
       a.old_price,
       a.new_price,
       a.changed_by,
       a.changed_at,
       a.change_reason
FROM AOBS_PRICE_AUDIT a
JOIN AOBS_BOOK b
  ON b.book_id = a.book_id
ORDER BY a.audit_id;

SELECT c.customer_id,
       c.first_name || ' ' || c.last_name AS customer_name,
       o.order_id,
       o.order_date,
       o.order_status,
       o.total_amount
FROM AOBS_CUSTOMER c
JOIN AOBS_ORDERS o
  ON o.customer_id = c.customer_id
ORDER BY c.customer_id, o.order_date DESC;

SELECT r.return_id,
       b.title,
       oi.quantity AS purchased_qty,
       r.return_qty,
       r.return_status,
       r.authorization_no,
       r.refund_amount
FROM AOBS_RETURN r
JOIN AOBS_ORDER_ITEM oi
  ON oi.order_item_id = r.order_item_id
JOIN AOBS_BOOK b
  ON b.book_id = oi.book_id
ORDER BY r.return_id;
