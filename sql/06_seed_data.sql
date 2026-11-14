-- Development data for a fresh installation; this file is not safe to rerun unchanged.
-- Inserts rely on newly created sequences and the installed business triggers.
-- The final COMMIT persists the seed dataset.

SET SERVEROUTPUT ON SIZE UNLIMITED;
SET DEFINE OFF;
SET LINESIZE 220;
SET PAGESIZE 100;

ALTER SESSION SET NLS_DATE_FORMAT = 'YYYY-MM-DD';

INSERT INTO AOBS_CATEGORY
VALUES (
    SEQ_AOBS_CATEGORY.NEXTVAL,
    'Database and Data Engineering',
    'Database design, SQL, PL/SQL, administration, and data platforms.'
);

INSERT INTO AOBS_CATEGORY
VALUES (
    SEQ_AOBS_CATEGORY.NEXTVAL,
    'Artificial Intelligence',
    'Machine learning, intelligent systems, and responsible AI.'
);

INSERT INTO AOBS_CATEGORY
VALUES (
    SEQ_AOBS_CATEGORY.NEXTVAL,
    'Software Development',
    'Programming, architecture, testing, and software engineering.'
);

INSERT INTO AOBS_CATEGORY
VALUES (
    SEQ_AOBS_CATEGORY.NEXTVAL,
    'Business and Entrepreneurship',
    'Startups, leadership, management, and business strategy.'
);

INSERT INTO AOBS_CATEGORY
VALUES (
    SEQ_AOBS_CATEGORY.NEXTVAL,
    'Health and Wellness',
    'Healthcare, nutrition, wellness, and patient education.'
);

INSERT INTO AOBS_CATEGORY
VALUES (
    SEQ_AOBS_CATEGORY.NEXTVAL,
    'Science Fiction',
    'Fiction exploring future science, technology, and society.'
);

INSERT INTO AOBS_CATEGORY
VALUES (
    SEQ_AOBS_CATEGORY.NEXTVAL,
    'Children and Young Readers',
    'Educational and entertaining books for children.'
);

INSERT INTO AOBS_CATEGORY
VALUES (
    SEQ_AOBS_CATEGORY.NEXTVAL,
    'Canadian History and Culture',
    'Books about Canadian history, society, and culture.'
);

INSERT INTO AOBS_AUTHOR
VALUES (
    SEQ_AOBS_AUTHOR.NEXTVAL,
    'Maya',
    'Chen',
    'Canada',
    'Database educator specializing in practical relational design.'
);

INSERT INTO AOBS_AUTHOR
VALUES (
    SEQ_AOBS_AUTHOR.NEXTVAL,
    'Daniel',
    'Roberts',
    'United States',
    'Software architect and technical author.'
);

INSERT INTO AOBS_AUTHOR
VALUES (
    SEQ_AOBS_AUTHOR.NEXTVAL,
    'Leila',
    'Hassan',
    'Canada',
    'Researcher writing about responsible artificial intelligence.'
);

INSERT INTO AOBS_AUTHOR
VALUES (
    SEQ_AOBS_AUTHOR.NEXTVAL,
    'Owen',
    'McKay',
    'Canada',
    'Historian focused on Canadian communities and immigration.'
);

INSERT INTO AOBS_AUTHOR
VALUES (
    SEQ_AOBS_AUTHOR.NEXTVAL,
    'Priya',
    'Patel',
    'United Kingdom',
    'Entrepreneurship lecturer and startup mentor.'
);

INSERT INTO AOBS_AUTHOR
VALUES (
    SEQ_AOBS_AUTHOR.NEXTVAL,
    'Noah',
    'Williams',
    'Canada',
    'Healthcare technology writer and data analyst.'
);

INSERT INTO AOBS_AUTHOR
VALUES (
    SEQ_AOBS_AUTHOR.NEXTVAL,
    'Sofia',
    'Martinez',
    'Spain',
    'Science-fiction novelist exploring human and machine collaboration.'
);

INSERT INTO AOBS_AUTHOR
VALUES (
    SEQ_AOBS_AUTHOR.NEXTVAL,
    'Ethan',
    'Brooks',
    'Canada',
    'Children''s author and former elementary-school teacher.'
);

INSERT INTO AOBS_AUTHOR
VALUES (
    SEQ_AOBS_AUTHOR.NEXTVAL,
    'Grace',
    'Kim',
    'South Korea',
    'Machine-learning engineer and educator.'
);

INSERT INTO AOBS_AUTHOR
VALUES (
    SEQ_AOBS_AUTHOR.NEXTVAL,
    'Lucas',
    'Tremblay',
    'Canada',
    'Cloud developer and technical trainer.'
);

INSERT INTO AOBS_CUSTOMER
VALUES (
    SEQ_AOBS_CUSTOMER.NEXTVAL,
    'Amir',
    'Saad',
    'amir.saad@example.ca',
    '416-555-0101',
    'Toronto',
    'Ontario',
    'M1B 2K3',
    'ACTIVE',
    TRUNC(SYSDATE) - 180
);

INSERT INTO AOBS_CUSTOMER
VALUES (
    SEQ_AOBS_CUSTOMER.NEXTVAL,
    'Nadia',
    'George',
    'nadia.george@example.ca',
    '647-555-0102',
    'Scarborough',
    'Ontario',
    'M1P 4N7',
    'ACTIVE',
    TRUNC(SYSDATE) - 160
);

INSERT INTO AOBS_CUSTOMER
VALUES (
    SEQ_AOBS_CUSTOMER.NEXTVAL,
    'Michael',
    'Brown',
    'michael.brown@example.ca',
    '905-555-0103',
    'Mississauga',
    'Ontario',
    'L5B 3C1',
    'ACTIVE',
    TRUNC(SYSDATE) - 140
);

INSERT INTO AOBS_CUSTOMER
VALUES (
    SEQ_AOBS_CUSTOMER.NEXTVAL,
    'Sara',
    'Ahmed',
    'sara.ahmed@example.ca',
    '416-555-0104',
    'Toronto',
    'Ontario',
    'M4B 1B4',
    'ACTIVE',
    TRUNC(SYSDATE) - 120
);

INSERT INTO AOBS_CUSTOMER
VALUES (
    SEQ_AOBS_CUSTOMER.NEXTVAL,
    'David',
    'Wilson',
    'david.wilson@example.ca',
    '289-555-0105',
    'Hamilton',
    'Ontario',
    'L8P 2N2',
    'ACTIVE',
    TRUNC(SYSDATE) - 110
);

INSERT INTO AOBS_CUSTOMER
VALUES (
    SEQ_AOBS_CUSTOMER.NEXTVAL,
    'Emily',
    'Li',
    'emily.li@example.ca',
    '416-555-0106',
    'North York',
    'Ontario',
    'M2N 5V7',
    'ACTIVE',
    TRUNC(SYSDATE) - 90
);

INSERT INTO AOBS_CUSTOMER
VALUES (
    SEQ_AOBS_CUSTOMER.NEXTVAL,
    'Joseph',
    'Martin',
    'joseph.martin@example.ca',
    '613-555-0107',
    'Ottawa',
    'Ontario',
    'K1P 1J1',
    'ACTIVE',
    TRUNC(SYSDATE) - 80
);

INSERT INTO AOBS_CUSTOMER
VALUES (
    SEQ_AOBS_CUSTOMER.NEXTVAL,
    'Fatima',
    'Ali',
    'fatima.ali@example.ca',
    '647-555-0108',
    'Etobicoke',
    'Ontario',
    'M9B 2A1',
    'ACTIVE',
    TRUNC(SYSDATE) - 70
);

INSERT INTO AOBS_CUSTOMER
VALUES (
    SEQ_AOBS_CUSTOMER.NEXTVAL,
    'Ryan',
    'Taylor',
    'ryan.taylor@example.ca',
    '905-555-0109',
    'Brampton',
    'Ontario',
    'L6V 1A2',
    'INACTIVE',
    TRUNC(SYSDATE) - 60
);

INSERT INTO AOBS_CUSTOMER
VALUES (
    SEQ_AOBS_CUSTOMER.NEXTVAL,
    'Olivia',
    'Clark',
    'olivia.clark@example.ca',
    '416-555-0110',
    'Toronto',
    'Ontario',
    'M5V 2T6',
    'ACTIVE',
    TRUNC(SYSDATE) - 45
);

INSERT INTO AOBS_BOOK (
    book_id, category_id, isbn13, title, book_description,
    publication_date, list_price, stock_qty, reorder_level, active_flag
)
VALUES (
    SEQ_AOBS_BOOK.NEXTVAL, 1, '9780134802749',
    'Practical Relational Database Design',
    'A case-based introduction to normalization, keys, and integrity.',
    DATE '2024-01-15', 44.99, 25, 6, 'Y'
);

INSERT INTO AOBS_BOOK (
    book_id, category_id, isbn13, title, book_description,
    publication_date, list_price, stock_qty, reorder_level, active_flag
)
VALUES (
    SEQ_AOBS_BOOK.NEXTVAL, 1, '9780135974445',
    'Oracle SQL and PL/SQL in Practice',
    'Hands-on Oracle queries, procedures, functions, packages, and triggers.',
    DATE '2025-02-10', 59.99, 20, 5, 'Y'
);

INSERT INTO AOBS_BOOK (
    book_id, category_id, isbn13, title, book_description,
    publication_date, list_price, stock_qty, reorder_level, active_flag
)
VALUES (
    SEQ_AOBS_BOOK.NEXTVAL, 2, '9780262048019',
    'Responsible Artificial Intelligence',
    'Practical methods for fair, transparent, and accountable AI systems.',
    DATE '2024-05-21', 34.99, 30, 7, 'Y'
);

INSERT INTO AOBS_BOOK (
    book_id, category_id, isbn13, title, book_description,
    publication_date, list_price, stock_qty, reorder_level, active_flag
)
VALUES (
    SEQ_AOBS_BOOK.NEXTVAL, 2, '9781492096480',
    'Machine Learning for Real Projects',
    'A project-focused guide to building and evaluating ML solutions.',
    DATE '2025-03-18', 52.50, 18, 5, 'Y'
);

INSERT INTO AOBS_BOOK (
    book_id, category_id, isbn13, title, book_description,
    publication_date, list_price, stock_qty, reorder_level, active_flag
)
VALUES (
    SEQ_AOBS_BOOK.NEXTVAL, 3, '9780135957059',
    'Modern Software Engineering',
    'Architecture, collaboration, testing, delivery, and maintainability.',
    DATE '2023-09-12', 49.95, 22, 5, 'Y'
);

INSERT INTO AOBS_BOOK (
    book_id, category_id, isbn13, title, book_description,
    publication_date, list_price, stock_qty, reorder_level, active_flag
)
VALUES (
    SEQ_AOBS_BOOK.NEXTVAL, 3, '9781098142421',
    'Cloud Applications with Java',
    'Building reliable Java services for cloud environments.',
    DATE '2025-01-28', 54.00, 16, 4, 'Y'
);

INSERT INTO AOBS_BOOK (
    book_id, category_id, isbn13, title, book_description,
    publication_date, list_price, stock_qty, reorder_level, active_flag
)
VALUES (
    SEQ_AOBS_BOOK.NEXTVAL, 4, '9781119832219',
    'From Startup Idea to Market',
    'Customer discovery, business models, testing, and launch planning.',
    DATE '2024-02-14', 31.75, 28, 6, 'Y'
);

INSERT INTO AOBS_BOOK (
    book_id, category_id, isbn13, title, book_description,
    publication_date, list_price, stock_qty, reorder_level, active_flag
)
VALUES (
    SEQ_AOBS_BOOK.NEXTVAL, 5, '9781770417439',
    'Digital Health for Better Care',
    'How data and software can support safer patient-centred healthcare.',
    DATE '2025-04-05', 39.50, 24, 5, 'Y'
);

INSERT INTO AOBS_BOOK (
    book_id, category_id, isbn13, title, book_description,
    publication_date, list_price, stock_qty, reorder_level, active_flag
)
VALUES (
    SEQ_AOBS_BOOK.NEXTVAL, 6, '9780385689227',
    'The Last Human Algorithm',
    'A science-fiction story about trust between people and intelligent machines.',
    DATE '2024-10-08', 24.99, 35, 8, 'Y'
);

INSERT INTO AOBS_BOOK (
    book_id, category_id, isbn13, title, book_description,
    publication_date, list_price, stock_qty, reorder_level, active_flag
)
VALUES (
    SEQ_AOBS_BOOK.NEXTVAL, 7, '9780735266712',
    'Robots at Maple School',
    'A young-reader adventure introducing robotics and teamwork.',
    DATE '2023-06-06', 16.99, 40, 10, 'Y'
);

INSERT INTO AOBS_BOOK (
    book_id, category_id, isbn13, title, book_description,
    publication_date, list_price, stock_qty, reorder_level, active_flag
)
VALUES (
    SEQ_AOBS_BOOK.NEXTVAL, 8, '9781487008302',
    'Stories of New Canadians',
    'Community stories about building a life in Canada.',
    DATE '2024-07-01', 27.50, 26, 6, 'Y'
);

INSERT INTO AOBS_BOOK (
    book_id, category_id, isbn13, title, book_description,
    publication_date, list_price, stock_qty, reorder_level, active_flag
)
VALUES (
    SEQ_AOBS_BOOK.NEXTVAL, 8, '9780771051716',
    'Canada Through Ten Turning Points',
    'An accessible history of events that shaped modern Canada.',
    DATE '2023-11-11', 29.95, 21, 5, 'Y'
);

INSERT INTO AOBS_BOOK_AUTHOR VALUES (1, 1, 'AUTHOR');
INSERT INTO AOBS_BOOK_AUTHOR VALUES (1, 2, 'CO-AUTHOR');
INSERT INTO AOBS_BOOK_AUTHOR VALUES (2, 1, 'AUTHOR');
INSERT INTO AOBS_BOOK_AUTHOR VALUES (2, 10, 'CO-AUTHOR');
INSERT INTO AOBS_BOOK_AUTHOR VALUES (3, 3, 'AUTHOR');
INSERT INTO AOBS_BOOK_AUTHOR VALUES (4, 9, 'AUTHOR');
INSERT INTO AOBS_BOOK_AUTHOR VALUES (5, 2, 'AUTHOR');
INSERT INTO AOBS_BOOK_AUTHOR VALUES (6, 10, 'AUTHOR');
INSERT INTO AOBS_BOOK_AUTHOR VALUES (7, 5, 'AUTHOR');
INSERT INTO AOBS_BOOK_AUTHOR VALUES (8, 6, 'AUTHOR');
INSERT INTO AOBS_BOOK_AUTHOR VALUES (8, 3, 'CO-AUTHOR');
INSERT INTO AOBS_BOOK_AUTHOR VALUES (9, 7, 'AUTHOR');
INSERT INTO AOBS_BOOK_AUTHOR VALUES (10, 8, 'AUTHOR');
INSERT INTO AOBS_BOOK_AUTHOR VALUES (11, 4, 'AUTHOR');
INSERT INTO AOBS_BOOK_AUTHOR VALUES (12, 4, 'AUTHOR');

INSERT INTO AOBS_ORDERS
VALUES (
    SEQ_AOBS_ORDER.NEXTVAL, 1, TRUNC(SYSDATE) - 12,
    'DELIVERED', TRUNC(SYSDATE) - 9, 0,
    '100 Progress Avenue, Toronto, ON M1G 3T8', USER
);

INSERT INTO AOBS_ORDERS
VALUES (
    SEQ_AOBS_ORDER.NEXTVAL, 2, TRUNC(SYSDATE) - 10,
    'DELIVERED', TRUNC(SYSDATE) - 7, 0,
    '25 Borough Drive, Scarborough, ON M1P 4N7', USER
);

INSERT INTO AOBS_ORDERS
VALUES (
    SEQ_AOBS_ORDER.NEXTVAL, 3, TRUNC(SYSDATE) - 8,
    'DELIVERED', TRUNC(SYSDATE) - 5, 0,
    '300 City Centre Drive, Mississauga, ON L5B 3C1', USER
);

INSERT INTO AOBS_ORDERS
VALUES (
    SEQ_AOBS_ORDER.NEXTVAL, 4, TRUNC(SYSDATE) - 6,
    'DELIVERED', TRUNC(SYSDATE) - 3, 0,
    '700 Danforth Avenue, Toronto, ON M4J 1L1', USER
);

INSERT INTO AOBS_ORDERS
VALUES (
    SEQ_AOBS_ORDER.NEXTVAL, 5, TRUNC(SYSDATE) - 4,
    'SHIPPED', NULL, 0,
    '50 Main Street West, Hamilton, ON L8P 1H6', USER
);

INSERT INTO AOBS_ORDERS
VALUES (
    SEQ_AOBS_ORDER.NEXTVAL, 6, TRUNC(SYSDATE),
    'PROCESSING', NULL, 0,
    '5100 Yonge Street, North York, ON M2N 5V7', USER
);

INSERT INTO AOBS_ORDERS
VALUES (
    SEQ_AOBS_ORDER.NEXTVAL, 7, TRUNC(SYSDATE) - 25,
    'DELIVERED', TRUNC(SYSDATE) - 21, 0,
    '110 Laurier Avenue West, Ottawa, ON K1P 1J1', USER
);

INSERT INTO AOBS_ORDERS
VALUES (
    SEQ_AOBS_ORDER.NEXTVAL, 8, TRUNC(SYSDATE) - 18,
    'DELIVERED', TRUNC(SYSDATE) - 14, 0,
    '399 The West Mall, Etobicoke, ON M9C 2Y2', USER
);

INSERT INTO AOBS_ORDERS
VALUES (
    SEQ_AOBS_ORDER.NEXTVAL, 9, TRUNC(SYSDATE) - 15,
    'CANCELLED', NULL, 0,
    '2 Wellington Street West, Brampton, ON L6Y 4R2', USER
);

INSERT INTO AOBS_ORDERS
VALUES (
    SEQ_AOBS_ORDER.NEXTVAL, 10, TRUNC(SYSDATE) - 3,
    'DELIVERED', TRUNC(SYSDATE) - 1, 0,
    '10 Front Street West, Toronto, ON M5J 2N1', USER
);

INSERT INTO AOBS_ORDER_ITEM VALUES (
    SEQ_AOBS_ORDER_ITEM.NEXTVAL, 1, 1, 2, 1, 1
);
INSERT INTO AOBS_ORDER_ITEM VALUES (
    SEQ_AOBS_ORDER_ITEM.NEXTVAL, 1, 2, 1, 1, 1
);

INSERT INTO AOBS_ORDER_ITEM VALUES (
    SEQ_AOBS_ORDER_ITEM.NEXTVAL, 2, 3, 1, 1, 1
);
INSERT INTO AOBS_ORDER_ITEM VALUES (
    SEQ_AOBS_ORDER_ITEM.NEXTVAL, 2, 4, 2, 1, 1
);

INSERT INTO AOBS_ORDER_ITEM VALUES (
    SEQ_AOBS_ORDER_ITEM.NEXTVAL, 3, 5, 1, 1, 1
);
INSERT INTO AOBS_ORDER_ITEM VALUES (
    SEQ_AOBS_ORDER_ITEM.NEXTVAL, 3, 6, 1, 1, 1
);

INSERT INTO AOBS_ORDER_ITEM VALUES (
    SEQ_AOBS_ORDER_ITEM.NEXTVAL, 4, 7, 2, 1, 1
);

INSERT INTO AOBS_ORDER_ITEM VALUES (
    SEQ_AOBS_ORDER_ITEM.NEXTVAL, 5, 8, 1, 1, 1
);
INSERT INTO AOBS_ORDER_ITEM VALUES (
    SEQ_AOBS_ORDER_ITEM.NEXTVAL, 5, 1, 1, 1, 1
);

INSERT INTO AOBS_ORDER_ITEM VALUES (
    SEQ_AOBS_ORDER_ITEM.NEXTVAL, 6, 9, 2, 1, 1
);

INSERT INTO AOBS_ORDER_ITEM VALUES (
    SEQ_AOBS_ORDER_ITEM.NEXTVAL, 7, 10, 1, 1, 1
);
INSERT INTO AOBS_ORDER_ITEM VALUES (
    SEQ_AOBS_ORDER_ITEM.NEXTVAL, 7, 11, 1, 1, 1
);

INSERT INTO AOBS_ORDER_ITEM VALUES (
    SEQ_AOBS_ORDER_ITEM.NEXTVAL, 8, 12, 1, 1, 1
);

INSERT INTO AOBS_ORDER_ITEM VALUES (
    SEQ_AOBS_ORDER_ITEM.NEXTVAL, 10, 2, 2, 1, 1
);
INSERT INTO AOBS_ORDER_ITEM VALUES (
    SEQ_AOBS_ORDER_ITEM.NEXTVAL, 10, 5, 1, 1, 1
);

INSERT INTO AOBS_RETURN (
    return_id, order_item_id, return_date, return_qty, return_reason,
    return_status, authorization_no, refund_amount, processed_by
)
VALUES (
    SEQ_AOBS_RETURN.NEXTVAL, 1, TRUNC(SYSDATE) - 7, 1,
    'One copy was damaged during delivery.',
    'APPROVED', NULL, 0, NULL
);

INSERT INTO AOBS_RETURN (
    return_id, order_item_id, return_date, return_qty, return_reason,
    return_status, authorization_no, refund_amount, processed_by
)
VALUES (
    SEQ_AOBS_RETURN.NEXTVAL, 3, TRUNC(SYSDATE) - 5, 1,
    'Customer ordered the wrong edition.',
    'APPROVED', NULL, 0, NULL
);

INSERT INTO AOBS_RETURN (
    return_id, order_item_id, return_date, return_qty, return_reason,
    return_status, authorization_no, refund_amount, processed_by
)
VALUES (
    SEQ_AOBS_RETURN.NEXTVAL, 4, TRUNC(SYSDATE) - 2, 1,
    'Customer requested a return review.',
    'PENDING', NULL, 0, NULL
);

INSERT INTO AOBS_RETURN (
    return_id, order_item_id, return_date, return_qty, return_reason,
    return_status, authorization_no, refund_amount, processed_by
)
VALUES (
    SEQ_AOBS_RETURN.NEXTVAL, 5, TRUNC(SYSDATE) - 2, 1,
    'Book arrived with torn pages.',
    'APPROVED', NULL, 0, NULL
);

INSERT INTO AOBS_RETURN (
    return_id, order_item_id, return_date, return_qty, return_reason,
    return_status, authorization_no, refund_amount, processed_by
)
VALUES (
    SEQ_AOBS_RETURN.NEXTVAL, 6, TRUNC(SYSDATE) - 1, 1,
    'Return request did not meet policy conditions.',
    'REJECTED', NULL, 0, USER
);

INSERT INTO AOBS_RETURN (
    return_id, order_item_id, return_date, return_qty, return_reason,
    return_status, authorization_no, refund_amount, processed_by
)
VALUES (
    SEQ_AOBS_RETURN.NEXTVAL, 7, TRUNC(SYSDATE) - 1, 1,
    'One of two copies was no longer required.',
    'APPROVED', NULL, 0, NULL
);

INSERT INTO AOBS_RETURN (
    return_id, order_item_id, return_date, return_qty, return_reason,
    return_status, authorization_no, refund_amount, processed_by
)
VALUES (
    SEQ_AOBS_RETURN.NEXTVAL, 8, TRUNC(SYSDATE), 1,
    'Order has not yet been delivered.',
    'REJECTED', NULL, 0, USER
);

INSERT INTO AOBS_RETURN (
    return_id, order_item_id, return_date, return_qty, return_reason,
    return_status, authorization_no, refund_amount, processed_by
)
VALUES (
    SEQ_AOBS_RETURN.NEXTVAL, 9, TRUNC(SYSDATE), 1,
    'Customer submitted a return request before delivery.',
    'PENDING', NULL, 0, NULL
);

INSERT INTO AOBS_RETURN (
    return_id, order_item_id, return_date, return_qty, return_reason,
    return_status, authorization_no, refund_amount, processed_by
)
VALUES (
    SEQ_AOBS_RETURN.NEXTVAL, 11, TRUNC(SYSDATE) - 18, 1,
    'Gift recipient already owned the book.',
    'APPROVED', NULL, 0, NULL
);

INSERT INTO AOBS_RETURN (
    return_id, order_item_id, return_date, return_qty, return_reason,
    return_status, authorization_no, refund_amount, processed_by
)
VALUES (
    SEQ_AOBS_RETURN.NEXTVAL, 12, TRUNC(SYSDATE) - 10, 1,
    'Customer asked staff to inspect the item.',
    'PENDING', NULL, 0, NULL
);

UPDATE AOBS_BOOK SET list_price = list_price + 1.00 WHERE book_id = 1;
UPDATE AOBS_BOOK SET list_price = list_price + 1.50 WHERE book_id = 2;
UPDATE AOBS_BOOK SET list_price = list_price + 0.75 WHERE book_id = 3;
UPDATE AOBS_BOOK SET list_price = list_price + 1.25 WHERE book_id = 4;
UPDATE AOBS_BOOK SET list_price = list_price + 1.00 WHERE book_id = 5;
UPDATE AOBS_BOOK SET list_price = list_price + 2.00 WHERE book_id = 6;
UPDATE AOBS_BOOK SET list_price = list_price + 0.50 WHERE book_id = 7;
UPDATE AOBS_BOOK SET list_price = list_price + 1.00 WHERE book_id = 8;
UPDATE AOBS_BOOK SET list_price = list_price + 0.50 WHERE book_id = 9;
UPDATE AOBS_BOOK SET list_price = list_price + 0.25 WHERE book_id = 10;

COMMIT;

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
