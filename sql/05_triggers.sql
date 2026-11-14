-- Triggers run within the caller transaction and maintain derived values.
-- Avoid duplicating their inventory, order-total, or refund updates in client code.

SET SERVEROUTPUT ON SIZE UNLIMITED;
SET DEFINE OFF;

CREATE OR REPLACE TRIGGER TRG_AOBS_BOOK_BIU
BEFORE INSERT OR UPDATE ON AOBS_BOOK
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        IF :NEW.book_id IS NULL THEN
            :NEW.book_id := SEQ_AOBS_BOOK.NEXTVAL;
        END IF;

        :NEW.created_at := NVL(:NEW.created_at, SYSDATE);
    END IF;

    :NEW.isbn13 := REPLACE(
        REPLACE(TRIM(:NEW.isbn13), '-', ''),
        ' ',
        ''
    );

    IF LENGTH(:NEW.isbn13) <> 13 OR
       NOT REGEXP_LIKE(:NEW.isbn13, '^[0-9]{13}$') THEN
        RAISE_APPLICATION_ERROR(
            -20101,
            'Book ISBN must contain exactly 13 numeric digits.'
        );
    END IF;

    IF :NEW.list_price IS NULL OR :NEW.list_price <= 0 THEN
        RAISE_APPLICATION_ERROR(
            -20102,
            'Book price must be greater than zero.'
        );
    END IF;

    IF :NEW.stock_qty IS NULL OR :NEW.stock_qty < 0 THEN
        RAISE_APPLICATION_ERROR(
            -20103,
            'Book stock quantity cannot be negative.'
        );
    END IF;

    IF :NEW.reorder_level IS NULL OR :NEW.reorder_level < 0 THEN
        RAISE_APPLICATION_ERROR(
            -20104,
            'Book reorder level cannot be negative.'
        );
    END IF;

    :NEW.updated_at := SYSDATE;
END;
/

SHOW ERRORS TRIGGER TRG_AOBS_BOOK_BIU;

CREATE OR REPLACE TRIGGER TRG_AOBS_BOOK_PRICE_AU
AFTER UPDATE OF list_price ON AOBS_BOOK
FOR EACH ROW
WHEN (OLD.list_price <> NEW.list_price)
BEGIN
    INSERT INTO AOBS_PRICE_AUDIT (
        audit_id,
        book_id,
        old_price,
        new_price,
        changed_by,
        changed_at,
        change_reason
    )
    VALUES (
        SEQ_AOBS_PRICE_AUDIT.NEXTVAL,
        :NEW.book_id,
        :OLD.list_price,
        :NEW.list_price,
        SYS_CONTEXT('USERENV', 'SESSION_USER'),
        SYSDATE,
        NVL(
            PKG_AMIR_BOOKSTORE.g_price_change_reason,
            'Direct SQL price change'
        )
    );
END;
/

SHOW ERRORS TRIGGER TRG_AOBS_BOOK_PRICE_AU;

CREATE OR REPLACE TRIGGER TRG_AOBS_ORDER_ITEM_BI
BEFORE INSERT ON AOBS_ORDER_ITEM
FOR EACH ROW
DECLARE
    v_current_price AOBS_BOOK.list_price%TYPE;
    v_current_stock AOBS_BOOK.stock_qty%TYPE;
    v_active_flag   AOBS_BOOK.active_flag%TYPE;
BEGIN
    IF :NEW.order_item_id IS NULL THEN
        :NEW.order_item_id := SEQ_AOBS_ORDER_ITEM.NEXTVAL;
    END IF;

    IF :NEW.quantity IS NULL OR :NEW.quantity <= 0 THEN
        RAISE_APPLICATION_ERROR(
            -20110,
            'Order-item quantity must be greater than zero.'
        );
    END IF;

    SELECT list_price,
           stock_qty,
           active_flag
    INTO v_current_price,
         v_current_stock,
         v_active_flag
    FROM AOBS_BOOK
    WHERE book_id = :NEW.book_id
    -- Lock the book row while validating stock for the new order item.
    FOR UPDATE;

    IF v_active_flag <> 'Y' THEN
        RAISE_APPLICATION_ERROR(
            -20111,
            'The selected book is inactive and cannot be ordered.'
        );
    END IF;

    IF v_current_stock < :NEW.quantity THEN
        RAISE_APPLICATION_ERROR(
            -20112,
            'Insufficient stock. Available=' || v_current_stock ||
            ', Requested=' || :NEW.quantity || '.'
        );
    END IF;

    :NEW.unit_price := v_current_price;
    :NEW.line_total := ROUND(v_current_price * :NEW.quantity, 2);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(
            -20113,
            'The selected Book ID does not exist.'
        );
END;
/

SHOW ERRORS TRIGGER TRG_AOBS_ORDER_ITEM_BI;

CREATE OR REPLACE TRIGGER TRG_AOBS_ORDER_ITEM_AI
AFTER INSERT ON AOBS_ORDER_ITEM
FOR EACH ROW
BEGIN
    UPDATE AOBS_BOOK
    SET stock_qty = stock_qty - :NEW.quantity
    WHERE book_id = :NEW.book_id;

    UPDATE AOBS_ORDERS
    SET total_amount = total_amount + :NEW.line_total
    WHERE order_id = :NEW.order_id;
END;
/

SHOW ERRORS TRIGGER TRG_AOBS_ORDER_ITEM_AI;

CREATE OR REPLACE TRIGGER TRG_AOBS_RETURN_BIU
BEFORE INSERT OR UPDATE ON AOBS_RETURN
FOR EACH ROW
DECLARE
    v_ordered_qty AOBS_ORDER_ITEM.quantity%TYPE;
    v_unit_price  AOBS_ORDER_ITEM.unit_price%TYPE;
BEGIN
    IF INSERTING AND :NEW.return_id IS NULL THEN
        :NEW.return_id := SEQ_AOBS_RETURN.NEXTVAL;
    END IF;

    SELECT quantity,
           unit_price
    INTO v_ordered_qty,
         v_unit_price
    FROM AOBS_ORDER_ITEM
    WHERE order_item_id = :NEW.order_item_id;

    IF :NEW.return_qty IS NULL OR :NEW.return_qty <= 0 THEN
        RAISE_APPLICATION_ERROR(
            -20120,
            'Return quantity must be greater than zero.'
        );
    END IF;

    IF :NEW.return_qty > v_ordered_qty THEN
        RAISE_APPLICATION_ERROR(
            -20121,
            'Return quantity cannot exceed the original purchased quantity.'
        );
    END IF;

    :NEW.return_date := NVL(:NEW.return_date, SYSDATE);

    IF :NEW.return_status = 'APPROVED' THEN
        IF :NEW.authorization_no IS NULL THEN
            :NEW.authorization_no := SEQ_AOBS_RETURN_AUTH.NEXTVAL;
        END IF;

        :NEW.refund_amount := ROUND(:NEW.return_qty * v_unit_price, 2);
        :NEW.processed_by  := NVL(
            :NEW.processed_by,
            SYS_CONTEXT('USERENV', 'SESSION_USER')
        );
    ELSE
        :NEW.refund_amount := 0;

        IF :NEW.return_status = 'PENDING' THEN
            :NEW.authorization_no := NULL;
            :NEW.processed_by := NULL;
        END IF;
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(
            -20122,
            'Return references an order item that does not exist.'
        );
END;
/

SHOW ERRORS TRIGGER TRG_AOBS_RETURN_BIU;

CREATE OR REPLACE TRIGGER TRG_AOBS_RETURN_AIU
AFTER INSERT OR UPDATE OF return_status, return_qty ON AOBS_RETURN
FOR EACH ROW
DECLARE
    v_book_id AOBS_ORDER_ITEM.book_id%TYPE;
    v_adjustment NUMBER;
BEGIN
    SELECT book_id
    INTO v_book_id
    FROM AOBS_ORDER_ITEM
    WHERE order_item_id = :NEW.order_item_id;

    IF INSERTING THEN
        IF :NEW.return_status = 'APPROVED' THEN
            v_adjustment := :NEW.return_qty;
        ELSE
            v_adjustment := 0;
        END IF;
    ELSE
        IF :OLD.return_status <> 'APPROVED' AND
           :NEW.return_status = 'APPROVED' THEN
            v_adjustment := :NEW.return_qty;

        ELSIF :OLD.return_status = 'APPROVED' AND
              :NEW.return_status <> 'APPROVED' THEN
            v_adjustment := -:OLD.return_qty;

        ELSIF :OLD.return_status = 'APPROVED' AND
              :NEW.return_status = 'APPROVED' THEN
            v_adjustment := :NEW.return_qty - :OLD.return_qty;

        ELSE
            v_adjustment := 0;
        END IF;
    END IF;

    IF v_adjustment <> 0 THEN
        UPDATE AOBS_BOOK
        SET stock_qty = stock_qty + v_adjustment
        WHERE book_id = v_book_id;
    END IF;
END;
/

SHOW ERRORS TRIGGER TRG_AOBS_RETURN_AIU;
