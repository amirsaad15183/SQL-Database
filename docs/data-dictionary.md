# Amir Online Book Store Database — Data Dictionary

## 1. AOBS_CATEGORY

Lookup table for valid bookstore categories.

| Column | Type | Rules | Meaning |
|---|---|---|---|
| `category_id` | `NUMBER(6)` | Primary key | Category identifier |
| `category_name` | `VARCHAR2(60)` | Not null, unique | Display/search category |
| `description` | `VARCHAR2(250)` | Optional | Category explanation |

Relationship: one category can contain many books.

## 2. AOBS_AUTHOR

Reference table for book contributors.

| Column | Type | Rules | Meaning |
|---|---|---|---|
| `author_id` | `NUMBER(8)` | Primary key | Author identifier |
| `first_name` | `VARCHAR2(50)` | Not null | Given name |
| `last_name` | `VARCHAR2(50)` | Not null | Family name |
| `country` | `VARCHAR2(60)` | Optional | Country |
| `biography` | `VARCHAR2(500)` | Optional | Short professional profile |

Relationship: authors connect to books through `AOBS_BOOK_AUTHOR`.

## 3. AOBS_CUSTOMER

Registered bookstore customers.

| Column | Type | Rules | Meaning |
|---|---|---|---|
| `customer_id` | `NUMBER(10)` | Primary key | Customer identifier |
| `first_name` | `VARCHAR2(50)` | Not null | First name |
| `last_name` | `VARCHAR2(50)` | Not null | Last name |
| `email` | `VARCHAR2(120)` | Not null, unique | Login/contact email |
| `phone` | `VARCHAR2(25)` | Optional | Telephone |
| `city` | `VARCHAR2(60)` | Optional | City |
| `province` | `VARCHAR2(40)` | Optional | Province |
| `postal_code` | `VARCHAR2(12)` | Optional | Postal code |
| `status` | `VARCHAR2(12)` | Active/inactive/suspended | Account status |
| `created_at` | `DATE` | Default `SYSDATE` | Registration date |

Relationship: one customer can place many orders.

## 4. AOBS_BOOK

Book catalogue and inventory.

| Column | Type | Rules | Meaning |
|---|---|---|---|
| `book_id` | `NUMBER(10)` | Primary key | Book identifier |
| `category_id` | `NUMBER(6)` | Foreign key | Book category |
| `isbn13` | `VARCHAR2(20)` | Unique; trigger removes spaces/hyphens and stores exactly 13 digits | ISBN |
| `title` | `VARCHAR2(200)` | Not null | Searchable title |
| `book_description` | `VARCHAR2(1000)` | Optional | Catalogue description |
| `publication_date` | `DATE` | Optional | Publication date |
| `list_price` | `NUMBER(10,2)` | Greater than zero | Current selling price |
| `stock_qty` | `NUMBER(8)` | Nonnegative | Available quantity |
| `reorder_level` | `NUMBER(8)` | Nonnegative | Restock threshold |
| `active_flag` | `CHAR(1)` | Y/N | Available for sale |
| `created_at` | `DATE` | Automatic | Creation timestamp |
| `updated_at` | `DATE` | Automatic | Last update timestamp |

Relationships:
- many books belong to one category;
- books connect to authors through `AOBS_BOOK_AUTHOR`;
- one book can appear in many order items;
- one book can have many price-audit rows.

## 5. AOBS_BOOK_AUTHOR

Junction table resolving the many-to-many relationship.

| Column | Type | Rules | Meaning |
|---|---|---|---|
| `book_id` | `NUMBER(10)` | Composite PK, FK | Book |
| `author_id` | `NUMBER(8)` | Composite PK, FK | Contributor |
| `author_role` | `VARCHAR2(30)` | Controlled values | Author, co-author, editor, translator |

## 6. AOBS_ORDERS

Order-header table.

| Column | Type | Rules | Meaning |
|---|---|---|---|
| `order_id` | `NUMBER(12)` | Primary key | Order identifier |
| `customer_id` | `NUMBER(10)` | Foreign key | Customer |
| `order_date` | `DATE` | Default `SYSDATE` | Date ordered |
| `order_status` | `VARCHAR2(15)` | Controlled values | Processing/shipped/delivered/cancelled |
| `delivery_date` | `DATE` | On/after order date | Date delivered |
| `total_amount` | `NUMBER(12,2)` | Nonnegative | Trigger-maintained total |
| `shipping_address` | `VARCHAR2(250)` | Not null | Destination |
| `created_by` | `VARCHAR2(30)` | Default database user | Creator |

Relationship: one order contains many order items.

## 7. AOBS_ORDER_ITEM

Order-detail table.

| Column | Type | Rules | Meaning |
|---|---|---|---|
| `order_item_id` | `NUMBER(12)` | Primary key | Line identifier |
| `order_id` | `NUMBER(12)` | Foreign key | Parent order |
| `book_id` | `NUMBER(10)` | Foreign key | Purchased book |
| `quantity` | `NUMBER(6)` | Greater than zero | Quantity ordered |
| `unit_price` | `NUMBER(10,2)` | Automatic | Historical purchase price |
| `line_total` | `NUMBER(12,2)` | Automatic | Quantity × unit price |

Relationship: one order item can have multiple return records over time, subject to package validation.

## 8. AOBS_RETURN

Return transaction table.

| Column | Type | Rules | Meaning |
|---|---|---|---|
| `return_id` | `NUMBER(12)` | Primary key | Return identifier |
| `order_item_id` | `NUMBER(12)` | Foreign key | Original purchase line |
| `return_date` | `DATE` | Default `SYSDATE` | Request/processing date |
| `return_qty` | `NUMBER(6)` | Greater than zero | Quantity returned |
| `return_reason` | `VARCHAR2(250)` | Not null | Customer/staff explanation |
| `return_status` | `VARCHAR2(12)` | Pending/approved/rejected | Workflow status |
| `authorization_no` | `NUMBER(12)` | Unique | Sequence-generated approval number |
| `refund_amount` | `NUMBER(12,2)` | Automatic, nonnegative | Refund |
| `processed_by` | `VARCHAR2(30)` | Automatic for approval | Staff/database user |

## 9. AOBS_PRICE_AUDIT

Audit/log table for price changes.

| Column | Type | Rules | Meaning |
|---|---|---|---|
| `audit_id` | `NUMBER(12)` | Primary key | Audit identifier |
| `book_id` | `NUMBER(10)` | Foreign key | Changed book |
| `old_price` | `NUMBER(10,2)` | Positive | Previous value |
| `new_price` | `NUMBER(10,2)` | Positive | New value |
| `changed_by` | `VARCHAR2(30)` | Automatic | Database username |
| `changed_at` | `DATE` | Automatic | Change timestamp |
| `change_reason` | `VARCHAR2(200)` | Package/trigger value | Business reason |
