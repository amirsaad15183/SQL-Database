SET DEFINE OFF;
SET SERVEROUTPUT ON SIZE UNLIMITED;

ALTER SESSION SET NLS_DATE_FORMAT = 'YYYY-MM-DD';

CREATE TABLE AOBS_CATEGORY (
    category_id    NUMBER(6)       NOT NULL,
    category_name  VARCHAR2(60)    NOT NULL,
    description    VARCHAR2(250),

    CONSTRAINT PK_AOBS_CATEGORY
        PRIMARY KEY (category_id),

    CONSTRAINT UQ_AOBS_CATEGORY_NAME
        UNIQUE (category_name)
);

CREATE TABLE AOBS_AUTHOR (
    author_id    NUMBER(8)       NOT NULL,
    first_name   VARCHAR2(50)    NOT NULL,
    last_name    VARCHAR2(50)    NOT NULL,
    country      VARCHAR2(60),
    biography    VARCHAR2(500),

    CONSTRAINT PK_AOBS_AUTHOR
        PRIMARY KEY (author_id)
);

CREATE TABLE AOBS_CUSTOMER (
    customer_id   NUMBER(10)       NOT NULL,
    first_name    VARCHAR2(50)     NOT NULL,
    last_name     VARCHAR2(50)     NOT NULL,
    email         VARCHAR2(120)    NOT NULL,
    phone         VARCHAR2(25),
    city          VARCHAR2(60),
    province      VARCHAR2(40),
    postal_code   VARCHAR2(12),
    status        VARCHAR2(12)     DEFAULT 'ACTIVE' NOT NULL,
    created_at    DATE             DEFAULT SYSDATE NOT NULL,

    CONSTRAINT PK_AOBS_CUSTOMER
        PRIMARY KEY (customer_id),

    CONSTRAINT UQ_AOBS_CUSTOMER_EMAIL
        UNIQUE (email),

    CONSTRAINT CK_AOBS_CUSTOMER_STATUS
        CHECK (status IN ('ACTIVE', 'INACTIVE', 'SUSPENDED'))
);

CREATE TABLE AOBS_BOOK (
    book_id           NUMBER(10)       NOT NULL,
    category_id       NUMBER(6)        NOT NULL,
    isbn13            VARCHAR2(20)     NOT NULL,
    title             VARCHAR2(200)    NOT NULL,
    book_description  VARCHAR2(1000),
    publication_date  DATE,
    list_price        NUMBER(10,2)     NOT NULL,
    stock_qty         NUMBER(8)        DEFAULT 0 NOT NULL,
    reorder_level     NUMBER(8)        DEFAULT 5 NOT NULL,
    active_flag       CHAR(1)          DEFAULT 'Y' NOT NULL,
    created_at        DATE             DEFAULT SYSDATE NOT NULL,
    updated_at        DATE             DEFAULT SYSDATE NOT NULL,

    CONSTRAINT PK_AOBS_BOOK
        PRIMARY KEY (book_id),

    CONSTRAINT UQ_AOBS_BOOK_ISBN13
        UNIQUE (isbn13),

    CONSTRAINT FK_AOBS_BOOK_CATEGORY
        FOREIGN KEY (category_id)
        REFERENCES AOBS_CATEGORY (category_id),

    CONSTRAINT CK_AOBS_BOOK_PRICE
        CHECK (list_price > 0),

    CONSTRAINT CK_AOBS_BOOK_STOCK
        CHECK (stock_qty >= 0),

    CONSTRAINT CK_AOBS_BOOK_REORDER
        CHECK (reorder_level >= 0),

    CONSTRAINT CK_AOBS_BOOK_ACTIVE
        CHECK (active_flag IN ('Y', 'N'))
);

CREATE TABLE AOBS_BOOK_AUTHOR (
    book_id      NUMBER(10)      NOT NULL,
    author_id    NUMBER(8)       NOT NULL,
    author_role  VARCHAR2(30)    DEFAULT 'AUTHOR' NOT NULL,

    CONSTRAINT PK_AOBS_BOOK_AUTHOR
        PRIMARY KEY (book_id, author_id),

    CONSTRAINT FK_AOBS_BA_BOOK
        FOREIGN KEY (book_id)
        REFERENCES AOBS_BOOK (book_id)
        ON DELETE CASCADE,

    CONSTRAINT FK_AOBS_BA_AUTHOR
        FOREIGN KEY (author_id)
        REFERENCES AOBS_AUTHOR (author_id),

    CONSTRAINT CK_AOBS_BA_ROLE
        CHECK (author_role IN ('AUTHOR', 'CO-AUTHOR', 'EDITOR', 'TRANSLATOR'))
);

CREATE TABLE AOBS_ORDERS (
    order_id          NUMBER(12)       NOT NULL,
    customer_id       NUMBER(10)       NOT NULL,
    order_date        DATE             DEFAULT SYSDATE NOT NULL,
    order_status      VARCHAR2(15)     DEFAULT 'PROCESSING' NOT NULL,
    delivery_date     DATE,
    total_amount      NUMBER(12,2)     DEFAULT 0 NOT NULL,
    shipping_address  VARCHAR2(250)    NOT NULL,
    created_by        VARCHAR2(30)     DEFAULT USER NOT NULL,

    CONSTRAINT PK_AOBS_ORDERS
        PRIMARY KEY (order_id),

    CONSTRAINT FK_AOBS_ORDER_CUSTOMER
        FOREIGN KEY (customer_id)
        REFERENCES AOBS_CUSTOMER (customer_id),

    CONSTRAINT CK_AOBS_ORDER_STATUS
        CHECK (
            order_status IN (
                'PROCESSING',
                'SHIPPED',
                'DELIVERED',
                'CANCELLED'
            )
        ),

    CONSTRAINT CK_AOBS_ORDER_TOTAL
        CHECK (total_amount >= 0),

    CONSTRAINT CK_AOBS_DELIVERY_DATE
        CHECK (delivery_date IS NULL OR delivery_date >= order_date)
);

CREATE TABLE AOBS_ORDER_ITEM (
    order_item_id  NUMBER(12)      NOT NULL,
    order_id       NUMBER(12)      NOT NULL,
    book_id        NUMBER(10)      NOT NULL,
    quantity       NUMBER(6)       NOT NULL,
    unit_price     NUMBER(10,2)    NOT NULL,
    line_total     NUMBER(12,2)    NOT NULL,

    CONSTRAINT PK_AOBS_ORDER_ITEM
        PRIMARY KEY (order_item_id),

    CONSTRAINT FK_AOBS_ITEM_ORDER
        FOREIGN KEY (order_id)
        REFERENCES AOBS_ORDERS (order_id)
        ON DELETE CASCADE,

    CONSTRAINT FK_AOBS_ITEM_BOOK
        FOREIGN KEY (book_id)
        REFERENCES AOBS_BOOK (book_id),

    CONSTRAINT CK_AOBS_ITEM_QUANTITY
        CHECK (quantity > 0),

    CONSTRAINT CK_AOBS_ITEM_UNIT_PRICE
        CHECK (unit_price > 0),

    CONSTRAINT CK_AOBS_ITEM_LINE_TOTAL
        CHECK (line_total > 0)
);

CREATE TABLE AOBS_RETURN (
    return_id          NUMBER(12)       NOT NULL,
    order_item_id      NUMBER(12)       NOT NULL,
    return_date        DATE             DEFAULT SYSDATE NOT NULL,
    return_qty         NUMBER(6)        NOT NULL,
    return_reason      VARCHAR2(250)    NOT NULL,
    return_status      VARCHAR2(12)     DEFAULT 'PENDING' NOT NULL,
    authorization_no   NUMBER(12),
    refund_amount      NUMBER(12,2)     DEFAULT 0 NOT NULL,
    processed_by       VARCHAR2(30),

    CONSTRAINT PK_AOBS_RETURN
        PRIMARY KEY (return_id),

    CONSTRAINT UQ_AOBS_RETURN_AUTH
        UNIQUE (authorization_no),

    CONSTRAINT FK_AOBS_RETURN_ITEM
        FOREIGN KEY (order_item_id)
        REFERENCES AOBS_ORDER_ITEM (order_item_id),

    CONSTRAINT CK_AOBS_RETURN_QTY
        CHECK (return_qty > 0),

    CONSTRAINT CK_AOBS_RETURN_STATUS
        CHECK (return_status IN ('PENDING', 'APPROVED', 'REJECTED')),

    CONSTRAINT CK_AOBS_RETURN_REFUND
        CHECK (refund_amount >= 0)
);

CREATE TABLE AOBS_PRICE_AUDIT (
    audit_id       NUMBER(12)       NOT NULL,
    book_id        NUMBER(10)       NOT NULL,
    old_price      NUMBER(10,2)     NOT NULL,
    new_price      NUMBER(10,2)     NOT NULL,
    changed_by     VARCHAR2(30)     NOT NULL,
    changed_at     DATE             DEFAULT SYSDATE NOT NULL,
    change_reason  VARCHAR2(200),

    CONSTRAINT PK_AOBS_PRICE_AUDIT
        PRIMARY KEY (audit_id),

    CONSTRAINT FK_AOBS_AUDIT_BOOK
        FOREIGN KEY (book_id)
        REFERENCES AOBS_BOOK (book_id),

    CONSTRAINT CK_AOBS_AUDIT_PRICES
        CHECK (old_price > 0 AND new_price > 0)
);
