-- Callers own COMMIT/ROLLBACK for package operations.
-- Reporting routines emit results through DBMS_OUTPUT.

SET SERVEROUTPUT ON SIZE UNLIMITED;
SET DEFINE OFF;

CREATE OR REPLACE PACKAGE PKG_AMIR_BOOKSTORE AS

    -- Session-local context consumed by the price-audit trigger.
    g_price_change_reason  VARCHAR2(200);

    PROCEDURE ADD_BOOK (
        p_isbn13            IN  AOBS_BOOK.isbn13%TYPE,
        p_category_id       IN  AOBS_BOOK.category_id%TYPE,
        p_title             IN  AOBS_BOOK.title%TYPE,
        p_description       IN  AOBS_BOOK.book_description%TYPE,
        p_publication_date  IN  AOBS_BOOK.publication_date%TYPE,
        p_list_price        IN  AOBS_BOOK.list_price%TYPE,
        p_stock_qty         IN  AOBS_BOOK.stock_qty%TYPE,
        p_reorder_level     IN  AOBS_BOOK.reorder_level%TYPE DEFAULT 5,
        p_book_id           OUT AOBS_BOOK.book_id%TYPE
    );

    PROCEDURE UPDATE_BOOK_PRICE (
        p_book_id        IN AOBS_BOOK.book_id%TYPE,
        p_new_price      IN AOBS_BOOK.list_price%TYPE,
        p_change_reason  IN AOBS_PRICE_AUDIT.change_reason%TYPE
                            DEFAULT 'Regular price maintenance'
    );

    PROCEDURE PLACE_ORDER (
        p_customer_id      IN  AOBS_CUSTOMER.customer_id%TYPE,
        p_book_id          IN  AOBS_BOOK.book_id%TYPE,
        p_quantity         IN  AOBS_ORDER_ITEM.quantity%TYPE,
        p_shipping_address IN  AOBS_ORDERS.shipping_address%TYPE,
        p_order_id         OUT AOBS_ORDERS.order_id%TYPE
    );

    PROCEDURE UPDATE_ORDER_STATUS (
        p_order_id      IN AOBS_ORDERS.order_id%TYPE,
        p_new_status    IN AOBS_ORDERS.order_status%TYPE,
        p_delivery_date IN AOBS_ORDERS.delivery_date%TYPE DEFAULT NULL
    );

    PROCEDURE PROCESS_RETURN (
        p_order_item_id IN  AOBS_ORDER_ITEM.order_item_id%TYPE,
        p_return_qty    IN  AOBS_RETURN.return_qty%TYPE,
        p_reason        IN  AOBS_RETURN.return_reason%TYPE,
        p_return_id     OUT AOBS_RETURN.return_id%TYPE
    );

    PROCEDURE GENERATE_WEEKLY_REPORT (
        p_week_start IN DATE DEFAULT TRUNC(SYSDATE, 'IW')
    );

    PROCEDURE GENERATE_MONTHLY_REPORT (
        p_month_start IN DATE DEFAULT TRUNC(SYSDATE, 'MM')
    );

    FUNCTION GET_BOOK_STOCK (
        p_book_id IN AOBS_BOOK.book_id%TYPE
    ) RETURN NUMBER;

    FUNCTION CALCULATE_ORDER_TOTAL (
        p_order_id IN AOBS_ORDERS.order_id%TYPE
    ) RETURN NUMBER;

    FUNCTION GET_CUSTOMER_TOTAL_SPENT (
        p_customer_id IN AOBS_CUSTOMER.customer_id%TYPE
    ) RETURN NUMBER;

    FUNCTION IS_RETURN_ELIGIBLE (
        p_order_item_id IN AOBS_ORDER_ITEM.order_item_id%TYPE,
        p_return_qty    IN AOBS_RETURN.return_qty%TYPE
    ) RETURN VARCHAR2;

END PKG_AMIR_BOOKSTORE;
/

SHOW ERRORS PACKAGE PKG_AMIR_BOOKSTORE;

CREATE OR REPLACE PACKAGE BODY PKG_AMIR_BOOKSTORE AS

    e_invalid_price       EXCEPTION;
    e_invalid_quantity    EXCEPTION;
    e_insufficient_stock  EXCEPTION;
    e_inactive_customer   EXCEPTION;
    e_invalid_status      EXCEPTION;
    e_return_not_allowed  EXCEPTION;

    CURSOR c_weekly_sales (
        cp_start_date IN DATE,
        cp_end_date   IN DATE
    ) IS
        SELECT b.book_id,
               b.title,
               SUM(oi.quantity) AS units_sold,
               SUM(oi.line_total) AS sales_amount
        FROM AOBS_BOOK b
        JOIN AOBS_ORDER_ITEM oi
          ON oi.book_id = b.book_id
        JOIN AOBS_ORDERS o
          ON o.order_id = oi.order_id
        WHERE o.order_date >= cp_start_date
          AND o.order_date < cp_end_date + 1
          AND o.order_status <> 'CANCELLED'
        GROUP BY b.book_id, b.title
        ORDER BY sales_amount DESC, b.title;

    CURSOR c_monthly_sales (
        cp_start_date IN DATE,
        cp_end_date   IN DATE
    ) IS
        SELECT c.category_id,
               c.category_name,
               SUM(oi.quantity) AS units_sold,
               SUM(oi.line_total) AS sales_amount
        FROM AOBS_CATEGORY c
        JOIN AOBS_BOOK b
          ON b.category_id = c.category_id
        JOIN AOBS_ORDER_ITEM oi
          ON oi.book_id = b.book_id
        JOIN AOBS_ORDERS o
          ON o.order_id = oi.order_id
        WHERE o.order_date >= cp_start_date
          AND o.order_date < cp_end_date + 1
          AND o.order_status <> 'CANCELLED'
        GROUP BY c.category_id, c.category_name
        ORDER BY sales_amount DESC, c.category_name;

    FUNCTION GET_BOOK_STOCK (
        p_book_id IN AOBS_BOOK.book_id%TYPE
    ) RETURN NUMBER IS
        v_stock AOBS_BOOK.stock_qty%TYPE;
    BEGIN
        SELECT stock_qty
        INTO v_stock
        FROM AOBS_BOOK
        WHERE book_id = p_book_id;

        RETURN v_stock;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(
                -20001,
                'GET_BOOK_STOCK: Book ID ' || p_book_id || ' does not exist.'
            );
    END GET_BOOK_STOCK;

    FUNCTION CALCULATE_ORDER_TOTAL (
        p_order_id IN AOBS_ORDERS.order_id%TYPE
    ) RETURN NUMBER IS
        v_customer_id AOBS_ORDERS.customer_id%TYPE;
        v_total       AOBS_ORDERS.total_amount%TYPE;
    BEGIN
        SELECT customer_id
        INTO v_customer_id
        FROM AOBS_ORDERS
        WHERE order_id = p_order_id;

        SELECT NVL(SUM(line_total), 0)
        INTO v_total
        FROM AOBS_ORDER_ITEM
        WHERE order_id = p_order_id;

        RETURN v_total;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(
                -20002,
                'CALCULATE_ORDER_TOTAL: Order ID ' || p_order_id ||
                ' does not exist.'
            );
    END CALCULATE_ORDER_TOTAL;

    FUNCTION GET_CUSTOMER_TOTAL_SPENT (
        p_customer_id IN AOBS_CUSTOMER.customer_id%TYPE
    ) RETURN NUMBER IS
        v_exists       NUMBER;
        v_gross_total  NUMBER(14,2);
        v_refunds      NUMBER(14,2);
    BEGIN
        SELECT COUNT(*)
        INTO v_exists
        FROM AOBS_CUSTOMER
        WHERE customer_id = p_customer_id;

        IF v_exists = 0 THEN
            RAISE_APPLICATION_ERROR(
                -20003,
                'GET_CUSTOMER_TOTAL_SPENT: Customer ID ' ||
                p_customer_id || ' does not exist.'
            );
        END IF;

        SELECT NVL(SUM(total_amount), 0)
        INTO v_gross_total
        FROM AOBS_ORDERS
        WHERE customer_id = p_customer_id
          AND order_status = 'DELIVERED';

        SELECT NVL(SUM(r.refund_amount), 0)
        INTO v_refunds
        FROM AOBS_RETURN r
        JOIN AOBS_ORDER_ITEM oi
          ON oi.order_item_id = r.order_item_id
        JOIN AOBS_ORDERS o
          ON o.order_id = oi.order_id
        WHERE o.customer_id = p_customer_id
          AND r.return_status = 'APPROVED';

        RETURN GREATEST(v_gross_total - v_refunds, 0);
    END GET_CUSTOMER_TOTAL_SPENT;

    FUNCTION IS_RETURN_ELIGIBLE (
        p_order_item_id IN AOBS_ORDER_ITEM.order_item_id%TYPE,
        p_return_qty    IN AOBS_RETURN.return_qty%TYPE
    ) RETURN VARCHAR2 IS
        v_item               AOBS_ORDER_ITEM%ROWTYPE;
        v_order              AOBS_ORDERS%ROWTYPE;
        v_already_returned   NUMBER;
    BEGIN
        IF p_return_qty IS NULL OR p_return_qty <= 0 THEN
            RETURN 'NO - Return quantity must be greater than zero.';
        END IF;

        SELECT *
        INTO v_item
        FROM AOBS_ORDER_ITEM
        WHERE order_item_id = p_order_item_id;

        SELECT *
        INTO v_order
        FROM AOBS_ORDERS
        WHERE order_id = v_item.order_id;

        IF v_order.order_status <> 'DELIVERED' THEN
            RETURN 'NO - Only delivered orders can be returned.';
        END IF;

        IF v_order.delivery_date IS NULL THEN
            RETURN 'NO - Delivery date is missing.';
        END IF;

        IF TRUNC(SYSDATE) - TRUNC(v_order.delivery_date) > 30 THEN
            RETURN 'NO - The 30-day return period has expired.';
        END IF;

        SELECT NVL(SUM(return_qty), 0)
        INTO v_already_returned
        FROM AOBS_RETURN
        WHERE order_item_id = p_order_item_id
          AND return_status = 'APPROVED';

        IF v_already_returned + p_return_qty > v_item.quantity THEN
            RETURN 'NO - Requested quantity exceeds the remaining returnable quantity.';
        END IF;

        RETURN 'YES';
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN 'NO - Order item does not exist.';
    END IS_RETURN_ELIGIBLE;

    PROCEDURE ADD_BOOK (
        p_isbn13            IN  AOBS_BOOK.isbn13%TYPE,
        p_category_id       IN  AOBS_BOOK.category_id%TYPE,
        p_title             IN  AOBS_BOOK.title%TYPE,
        p_description       IN  AOBS_BOOK.book_description%TYPE,
        p_publication_date  IN  AOBS_BOOK.publication_date%TYPE,
        p_list_price        IN  AOBS_BOOK.list_price%TYPE,
        p_stock_qty         IN  AOBS_BOOK.stock_qty%TYPE,
        p_reorder_level     IN  AOBS_BOOK.reorder_level%TYPE,
        p_book_id           OUT AOBS_BOOK.book_id%TYPE
    ) IS
        v_book            AOBS_BOOK%ROWTYPE;
        v_category_count  NUMBER;
    BEGIN
        IF p_list_price IS NULL OR p_list_price <= 0 THEN
            RAISE e_invalid_price;
        END IF;

        IF p_stock_qty IS NULL OR p_stock_qty < 0 OR
           p_reorder_level IS NULL OR p_reorder_level < 0 THEN
            RAISE e_invalid_quantity;
        END IF;

        SELECT COUNT(*)
        INTO v_category_count
        FROM AOBS_CATEGORY
        WHERE category_id = p_category_id;

        IF v_category_count = 0 THEN
            RAISE_APPLICATION_ERROR(
                -20010,
                'ADD_BOOK: Category ID ' || p_category_id || ' does not exist.'
            );
        END IF;

        p_book_id               := SEQ_AOBS_BOOK.NEXTVAL;
        v_book.book_id          := p_book_id;
        v_book.category_id      := p_category_id;
        v_book.isbn13           := REPLACE(REPLACE(TRIM(p_isbn13), '-', ''), ' ', '');
        v_book.title            := TRIM(p_title);
        v_book.book_description := p_description;
        v_book.publication_date := p_publication_date;
        v_book.list_price       := p_list_price;
        v_book.stock_qty        := p_stock_qty;
        v_book.reorder_level    := p_reorder_level;
        v_book.active_flag      := 'Y';
        v_book.created_at       := SYSDATE;
        v_book.updated_at       := SYSDATE;

        INSERT INTO AOBS_BOOK (
            book_id,
            category_id,
            isbn13,
            title,
            book_description,
            publication_date,
            list_price,
            stock_qty,
            reorder_level,
            active_flag,
            created_at,
            updated_at
        )
        VALUES (
            v_book.book_id,
            v_book.category_id,
            v_book.isbn13,
            v_book.title,
            v_book.book_description,
            v_book.publication_date,
            v_book.list_price,
            v_book.stock_qty,
            v_book.reorder_level,
            v_book.active_flag,
            v_book.created_at,
            v_book.updated_at
        );
    EXCEPTION
        WHEN e_invalid_price THEN
            RAISE_APPLICATION_ERROR(
                -20011,
                'ADD_BOOK: List price must be greater than zero.'
            );
        WHEN e_invalid_quantity THEN
            RAISE_APPLICATION_ERROR(
                -20012,
                'ADD_BOOK: Stock and reorder level cannot be negative.'
            );
        WHEN DUP_VAL_ON_INDEX THEN
            RAISE_APPLICATION_ERROR(
                -20013,
                'ADD_BOOK: The ISBN already exists in the catalogue.'
            );
        WHEN OTHERS THEN
            IF SQLCODE BETWEEN -20999 AND -20000 THEN
                RAISE;
            ELSE
                RAISE_APPLICATION_ERROR(
                    -20990,
                    'ADD_BOOK unexpected error: ' || SQLERRM
                );
            END IF;
    END ADD_BOOK;

    PROCEDURE UPDATE_BOOK_PRICE (
        p_book_id        IN AOBS_BOOK.book_id%TYPE,
        p_new_price      IN AOBS_BOOK.list_price%TYPE,
        p_change_reason  IN AOBS_PRICE_AUDIT.change_reason%TYPE
    ) IS
        v_book AOBS_BOOK%ROWTYPE;
    BEGIN
        SELECT *
        INTO v_book
        FROM AOBS_BOOK
        WHERE book_id = p_book_id
        FOR UPDATE;

        IF p_new_price IS NULL OR p_new_price <= 0 THEN
            RAISE e_invalid_price;
        END IF;

        IF p_new_price = v_book.list_price THEN
            RAISE_APPLICATION_ERROR(
                -20020,
                'UPDATE_BOOK_PRICE: New price must differ from current price.'
            );
        END IF;

        g_price_change_reason := SUBSTR(
            NVL(TRIM(p_change_reason), 'Regular price maintenance'),
            1,
            200
        );

        UPDATE AOBS_BOOK
        SET list_price = p_new_price
        WHERE book_id = p_book_id;

        g_price_change_reason := NULL;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            g_price_change_reason := NULL;
            RAISE_APPLICATION_ERROR(
                -20021,
                'UPDATE_BOOK_PRICE: Book ID ' || p_book_id || ' does not exist.'
            );
        WHEN e_invalid_price THEN
            g_price_change_reason := NULL;
            RAISE_APPLICATION_ERROR(
                -20022,
                'UPDATE_BOOK_PRICE: New price must be greater than zero.'
            );
        WHEN OTHERS THEN
            g_price_change_reason := NULL;
            IF SQLCODE BETWEEN -20999 AND -20000 THEN
                RAISE;
            ELSE
                RAISE_APPLICATION_ERROR(
                    -20991,
                    'UPDATE_BOOK_PRICE unexpected error: ' || SQLERRM
                );
            END IF;
    END UPDATE_BOOK_PRICE;

    PROCEDURE PLACE_ORDER (
        p_customer_id      IN  AOBS_CUSTOMER.customer_id%TYPE,
        p_book_id          IN  AOBS_BOOK.book_id%TYPE,
        p_quantity         IN  AOBS_ORDER_ITEM.quantity%TYPE,
        p_shipping_address IN  AOBS_ORDERS.shipping_address%TYPE,
        p_order_id         OUT AOBS_ORDERS.order_id%TYPE
    ) IS
        v_customer_status AOBS_CUSTOMER.status%TYPE;
        v_stock           AOBS_BOOK.stock_qty%TYPE;
    BEGIN
        IF p_quantity IS NULL OR p_quantity <= 0 THEN
            RAISE e_invalid_quantity;
        END IF;

        SELECT status
        INTO v_customer_status
        FROM AOBS_CUSTOMER
        WHERE customer_id = p_customer_id;

        IF v_customer_status <> 'ACTIVE' THEN
            RAISE e_inactive_customer;
        END IF;

        SELECT stock_qty
        INTO v_stock
        FROM AOBS_BOOK
        WHERE book_id = p_book_id
          AND active_flag = 'Y';

        IF v_stock < p_quantity THEN
            RAISE e_insufficient_stock;
        END IF;

        p_order_id := SEQ_AOBS_ORDER.NEXTVAL;

        INSERT INTO AOBS_ORDERS (
            order_id,
            customer_id,
            order_date,
            order_status,
            delivery_date,
            total_amount,
            shipping_address,
            created_by
        )
        VALUES (
            p_order_id,
            p_customer_id,
            SYSDATE,
            'PROCESSING',
            NULL,
            0,
            TRIM(p_shipping_address),
            USER
        );

        INSERT INTO AOBS_ORDER_ITEM (
            order_item_id,
            order_id,
            book_id,
            quantity,
            unit_price,
            line_total
        )
        VALUES (
            SEQ_AOBS_ORDER_ITEM.NEXTVAL,
            p_order_id,
            p_book_id,
            p_quantity,
            1,
            1
        );
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(
                -20030,
                'PLACE_ORDER: Customer or active book was not found.'
            );
        WHEN e_invalid_quantity THEN
            RAISE_APPLICATION_ERROR(
                -20031,
                'PLACE_ORDER: Quantity must be greater than zero.'
            );
        WHEN e_inactive_customer THEN
            RAISE_APPLICATION_ERROR(
                -20032,
                'PLACE_ORDER: Customer account is not ACTIVE.'
            );
        WHEN e_insufficient_stock THEN
            RAISE_APPLICATION_ERROR(
                -20033,
                'PLACE_ORDER: Insufficient inventory for Book ID ' || p_book_id || '.'
            );
        WHEN OTHERS THEN
            IF SQLCODE BETWEEN -20999 AND -20000 THEN
                RAISE;
            ELSE
                RAISE_APPLICATION_ERROR(
                    -20992,
                    'PLACE_ORDER unexpected error: ' || SQLERRM
                );
            END IF;
    END PLACE_ORDER;

    PROCEDURE UPDATE_ORDER_STATUS (
        p_order_id      IN AOBS_ORDERS.order_id%TYPE,
        p_new_status    IN AOBS_ORDERS.order_status%TYPE,
        p_delivery_date IN AOBS_ORDERS.delivery_date%TYPE
    ) IS
        v_count NUMBER;
    BEGIN
        IF p_new_status NOT IN (
            'PROCESSING',
            'SHIPPED',
            'DELIVERED',
            'CANCELLED'
        ) THEN
            RAISE e_invalid_status;
        END IF;

        SELECT COUNT(*)
        INTO v_count
        FROM AOBS_ORDERS
        WHERE order_id = p_order_id;

        IF v_count = 0 THEN
            RAISE_APPLICATION_ERROR(
                -20040,
                'UPDATE_ORDER_STATUS: Order ID ' || p_order_id || ' does not exist.'
            );
        END IF;

        UPDATE AOBS_ORDERS
        SET order_status = p_new_status,
            delivery_date =
                CASE
                    WHEN p_new_status = 'DELIVERED'
                        THEN NVL(p_delivery_date, SYSDATE)
                    ELSE NULL
                END
        WHERE order_id = p_order_id;
    EXCEPTION
        WHEN e_invalid_status THEN
            RAISE_APPLICATION_ERROR(
                -20041,
                'UPDATE_ORDER_STATUS: Invalid status value.'
            );
    END UPDATE_ORDER_STATUS;

    PROCEDURE PROCESS_RETURN (
        p_order_item_id IN  AOBS_ORDER_ITEM.order_item_id%TYPE,
        p_return_qty    IN  AOBS_RETURN.return_qty%TYPE,
        p_reason        IN  AOBS_RETURN.return_reason%TYPE,
        p_return_id     OUT AOBS_RETURN.return_id%TYPE
    ) IS
        v_eligibility VARCHAR2(200);
    BEGIN
        v_eligibility := IS_RETURN_ELIGIBLE(
            p_order_item_id,
            p_return_qty
        );

        IF v_eligibility <> 'YES' THEN
            RAISE e_return_not_allowed;
        END IF;

        p_return_id := SEQ_AOBS_RETURN.NEXTVAL;

        INSERT INTO AOBS_RETURN (
            return_id,
            order_item_id,
            return_date,
            return_qty,
            return_reason,
            return_status,
            authorization_no,
            refund_amount,
            processed_by
        )
        VALUES (
            p_return_id,
            p_order_item_id,
            SYSDATE,
            p_return_qty,
            TRIM(p_reason),
            'APPROVED',
            NULL,
            0,
            USER
        );
    EXCEPTION
        WHEN e_return_not_allowed THEN
            RAISE_APPLICATION_ERROR(
                -20050,
                'PROCESS_RETURN: ' || v_eligibility
            );
        WHEN OTHERS THEN
            IF SQLCODE BETWEEN -20999 AND -20000 THEN
                RAISE;
            ELSE
                RAISE_APPLICATION_ERROR(
                    -20993,
                    'PROCESS_RETURN unexpected error: ' || SQLERRM
                );
            END IF;
    END PROCESS_RETURN;

    PROCEDURE GENERATE_WEEKLY_REPORT (
        p_week_start IN DATE
    ) IS
        v_start_date  DATE := TRUNC(p_week_start);
        v_end_date    DATE := TRUNC(p_week_start) + 6;
        v_grand_total NUMBER(14,2) := 0;
        v_found       BOOLEAN := FALSE;
    BEGIN
        DBMS_OUTPUT.PUT_LINE(RPAD('=', 92, '='));
        DBMS_OUTPUT.PUT_LINE('AMIR ONLINE BOOK STORE - WEEKLY SALES REPORT');
        DBMS_OUTPUT.PUT_LINE(
            'Period: ' || TO_CHAR(v_start_date, 'YYYY-MM-DD') ||
            ' to ' || TO_CHAR(v_end_date, 'YYYY-MM-DD')
        );
        DBMS_OUTPUT.PUT_LINE(RPAD('-', 92, '-'));
        DBMS_OUTPUT.PUT_LINE(
            RPAD('BOOK ID', 10) ||
            RPAD('TITLE', 50) ||
            LPAD('UNITS', 10) ||
            LPAD('SALES', 18)
        );
        DBMS_OUTPUT.PUT_LINE(RPAD('-', 92, '-'));

        FOR r_sale IN c_weekly_sales(v_start_date, v_end_date) LOOP
            v_found := TRUE;
            v_grand_total := v_grand_total + r_sale.sales_amount;

            DBMS_OUTPUT.PUT_LINE(
                RPAD(TO_CHAR(r_sale.book_id), 10) ||
                RPAD(SUBSTR(r_sale.title, 1, 47), 50) ||
                LPAD(TO_CHAR(r_sale.units_sold), 10) ||
                LPAD(TO_CHAR(r_sale.sales_amount, 'FM$999,990.00'), 18)
            );
        END LOOP;

        IF NOT v_found THEN
            DBMS_OUTPUT.PUT_LINE('No sales were found for this week.');
        END IF;

        DBMS_OUTPUT.PUT_LINE(RPAD('-', 92, '-'));
        DBMS_OUTPUT.PUT_LINE(
            RPAD('WEEKLY TOTAL', 74) ||
            LPAD(TO_CHAR(v_grand_total, 'FM$999,999,990.00'), 18)
        );
        DBMS_OUTPUT.PUT_LINE(RPAD('=', 92, '='));
    END GENERATE_WEEKLY_REPORT;

    PROCEDURE GENERATE_MONTHLY_REPORT (
        p_month_start IN DATE
    ) IS
        v_start_date  DATE := TRUNC(p_month_start, 'MM');
        v_end_date    DATE := LAST_DAY(TRUNC(p_month_start, 'MM'));
        v_month_row   c_monthly_sales%ROWTYPE;
        v_grand_total NUMBER(14,2) := 0;
        v_found       BOOLEAN := FALSE;
    BEGIN
        DBMS_OUTPUT.PUT_LINE(RPAD('=', 82, '='));
        DBMS_OUTPUT.PUT_LINE('AMIR ONLINE BOOK STORE - MONTHLY CATEGORY REPORT');
        DBMS_OUTPUT.PUT_LINE(
            'Month: ' || TO_CHAR(v_start_date, 'Month YYYY')
        );
        DBMS_OUTPUT.PUT_LINE(RPAD('-', 82, '-'));
        DBMS_OUTPUT.PUT_LINE(
            RPAD('CATEGORY', 42) ||
            LPAD('UNITS', 12) ||
            LPAD('SALES', 22)
        );
        DBMS_OUTPUT.PUT_LINE(RPAD('-', 82, '-'));

        OPEN c_monthly_sales(v_start_date, v_end_date);

        LOOP
            FETCH c_monthly_sales INTO v_month_row;
            EXIT WHEN c_monthly_sales%NOTFOUND;

            v_found := TRUE;
            v_grand_total := v_grand_total + v_month_row.sales_amount;

            DBMS_OUTPUT.PUT_LINE(
                RPAD(SUBSTR(v_month_row.category_name, 1, 39), 42) ||
                LPAD(TO_CHAR(v_month_row.units_sold), 12) ||
                LPAD(
                    TO_CHAR(v_month_row.sales_amount, 'FM$999,999,990.00'),
                    22
                )
            );
        END LOOP;

        CLOSE c_monthly_sales;

        IF NOT v_found THEN
            DBMS_OUTPUT.PUT_LINE('No sales were found for this month.');
        END IF;

        DBMS_OUTPUT.PUT_LINE(RPAD('-', 82, '-'));
        DBMS_OUTPUT.PUT_LINE(
            RPAD('MONTHLY TOTAL', 60) ||
            LPAD(TO_CHAR(v_grand_total, 'FM$999,999,990.00'), 22)
        );
        DBMS_OUTPUT.PUT_LINE(RPAD('=', 82, '='));
    EXCEPTION
        WHEN OTHERS THEN
            IF c_monthly_sales%ISOPEN THEN
                CLOSE c_monthly_sales;
            END IF;
            RAISE;
    END GENERATE_MONTHLY_REPORT;

END PKG_AMIR_BOOKSTORE;
/

SHOW ERRORS PACKAGE BODY PKG_AMIR_BOOKSTORE;
