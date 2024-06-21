--Excluding the not needed columns from table olist_order_reviews
ALTER TABLE olist_order_reviews
DROP COLUMN review_comment_title, review_comment_message, review_creation_date, review_answer_timestamp;

--Excluding the not needed columns from table olist_geolocation
ALTER TABLE olist_geolocation
DROP COLUMN geolocation_lat, geolocation_lng;

--Deleting the 1st row from product_category_name_translation as the csv file took the headlines as data
DELETE FROM product_category_name_translation
WHERE product_category_name = 'product_category_name'

--setting FKs for each table
ALTER TABLE olist_orders
ADD CONSTRAINT fk_olist_orders_customer_id
FOREIGN KEY (customer_id)
REFERENCES olist_customers(customer_id);

ALTER TABLE olist_order_payments
ADD CONSTRAINT fk_olist_order_payments_order_id
FOREIGN KEY (order_id)
REFERENCES olist_orders(order_id);

ALTER TABLE olist_order_reviews
ADD CONSTRAINT fk_olist_order_reviews_order_id
FOREIGN KEY (order_id)
REFERENCES olist_orders(order_id);

ALTER TABLE olist_order_items
ADD CONSTRAINT fk_olist_order_items_order_id
FOREIGN KEY (order_id)
REFERENCES olist_orders(order_id);

ALTER TABLE olist_order_payments
ADD CONSTRAINT fk_olist_order_payments_order_id
FOREIGN KEY (order_id)
REFERENCES olist_orders(order_id);

ALTER TABLE olist_order_items
ADD CONSTRAINT fk_olist_order_items_seller_id
FOREIGN KEY (seller_id)
REFERENCES olist_sellers(seller_id);


ALTER TABLE olist_order_items
ADD CONSTRAINT fk_olist_order_items_product_id
FOREIGN KEY (product_id)
REFERENCES olist_products(product_id);


--Updating the olist_products to add the column ‘product_category_name_English’ from product_category_name_translation to make the upcoming queries more concise.
ALTER TABLE olist_products
ADD product_category_name_english VARCHAR(255);

UPDATE op
SET op.product_category_name_english = pcnt.product_category_name_english
FROM olist_products op
JOIN product_category_name_translation pcnt ON op.product_category_name = pcnt.product_category_name;


--Making sure that there are no empty values in product_category_name column
SELECT *
FROM olist_products
WHERE product_category_name = ''

--Setting the null values to 'No Data'
UPDATE olist_products
SET product_category_name = 'No Data'
WHERE product_category_name IS NULL

--Setting the matched values in english to 'No Data' as well
UPDATE olist_products
SET product_category_name_english = 'No Data'
WHERE product_category_name_english IS NULL

--Detecting the values that has no matches so we can translate them and vice-versa
SELECT product_category_name, product_category_name_english
FROM olist_products
WHERE product_category_name_english = 'NO Data'

UPDATE olist_products
SET product_category_name_english = 'portable kitchens and food preparers'
WHERE product_category_name = 'portateis_cozinha_e_preparadores_de_alimentos'

UPDATE olist_products
SET product_category_name_english = 'pc_gamer'
WHERE product_category_name = 'pc_gamer'



--Deleting typo values 
delete from olist_geolocation where geolocation_zip_code_prefix = 87365

/*separating location data from customers table into a new table by creating two table, one to store the distinct values of city and state then
copying these data into a second table with identity column to create values for zip_code while copying, this because I can't modify the identit column 
after creation*/

CREATE TABLE region
(
zip_code INT NOT NULL,
city VARCHAR(50) NOT NULL,
state VARCHAR(50) NOT NULL
);

CREATE TABLE region2
(
zip_code INT NOT NULL IDENTITY(2555,1),
city VARCHAR(50),
state VARCHAR(50)
);

--Extracting unique location data
INSERT INTO region2(city, state)
SELECT DISTINCT customer_city, customer_state FROM olist_customers

--copying data to target table
INSERT INTO region
SELECT * FROM region2

--Adding PRIMARY KEY CONSTRAINT to zip_code
--Now our table is ready
ALTER TABLE region
ADD CONSTRAINT PK_region PRIMARY KEY (zip_code);

--Dropping the temp table, we don't need it
DROP TABLE region2

--Check your work
SELECT * FROM region

--Adding a new table in customers table to attach the new table with as a FOREIGN KEY relationship
ALTER TABLE olist_customers
ADD zip_code INT; 

--Populating the new column with zip_code data from region
UPDATE oc
SET oc.zip_code = rg.zip_code
FROM olist_customers oc
JOIN region rg ON oc.customer_city = rg.city AND oc.customer_state = rg.state;

--Setting the relationship betwwen the customers table and region table
ALTER TABLE olist_customers
ADD CONSTRAINT fk_olist_customers_zip_code_region_zipCode
FOREIGN KEY(zip_code)
REFERENCES region(zip_code)

select * from olist_customers

ALTER TABLE olist_customers DROP column customer_zip_code_prefix,customer_city,customer_state

--Doing the same for sellers table, because there locations data 
ALTER TABLE olist_sellers
ADD zip_code INT; 

--Populating the new column with zip_code data from region
UPDATE slr
SET slr.zip_code = rg.zip_code
FROM olist_sellers slr
JOIN region rg ON slr.seller_city = rg.city AND slr.seller_state = rg.state;

--Setting the relationship between the seller table and region table
ALTER TABLE olist_sellers
ADD CONSTRAINT fk_olist_sellers_zip_code_region_zipCode
FOREIGN KEY(zip_code)
REFERENCES region(zip_code)

--Dropping the 2 not needed tables (olist_gelocation & product category name translation)
DROP TABLE olist_geolocation
DROP TABLE product_category_name_translation

--Excluding the not needed columns from table olist_sellers
ALTER TABLE olist_sellers
DROP COLUMN seller_city, seller_state, seller_zip_code_prefix;

--Excluding the not needed columns from table olist_products
ALTER TABLE olist_products
DROP COLUMN product_description_length, product_photos_qty, product_weight_g, product_length_cm, product_height_cm, product_width_cm, product_name_length
