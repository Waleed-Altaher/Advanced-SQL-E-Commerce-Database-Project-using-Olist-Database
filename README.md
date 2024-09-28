# Advanced-SQL-E-Commerce-Database-Project-using-Olist-Database
Explore advanced SQL techniques applied to the Olist e-commerce database for comprehensive data querying and analysis. Includes optimized database schema, complex queries for sales analytics, customer insights, and more. Ideal for SQL practical learning, real-world context.

# 1. Overview
This project discusses Olist database, Olist is a Brazilian e-commerce platform that connects small and medium-sized businesses to customers across Brazil. The platform operates as a marketplace, where merchants can list their products and services and customers can browse and purchase them online.

The Olist sales dataset available on Kaggle is a collection of anonymized data about orders placed on the Olist platform between January 2017 and August 2018. 

This dataset includes 9 CSV files as follows:
<details>
  <summary> 1. olist_customers_dataset.csv: </summary>
   
         a. customer_id: unique identifier for each customer
  
         b. customer_unique_id: unique identifier for each customer (anonymized)
    
         c. customer_zip_code_prefix: zip code prefix of the customer’s address
    
         d. customer_city: the city where the customer is located.
    
         e. customer_state: state where the customer is located
</details>

  
<details>
  <summary> 2. olist_geolocation_dataset.csv:  </summary>
     
      a. geolocation_zip_code_prefix: zip code prefix for the location
   
      b. geolocation_lat: latitude of the location
   
      c. geolocation_lng: longitude of the location
   
      d. geolocation_city: city of the location
   
      e. geolocation_state: state of the location
</details>
   
<details>
  <summary> 3. olist_orders_dataset.csv: </summary>
   
    a. order_id: unique identifier for each order
   
    b. customer_id: unique identifier for the customer who placed the order
   
    c. order_status: current status of the order (e.g. delivered, shipped, canceled)
   
    d. order_purchase_timestamp: date and time when the order was placed
   
    e. order_approved_at: date and time when the payment for the order was approved
   
    f. order_delivered_carrier_date: date and time when the order was handed over to the carrier
   
    g. order_delivered_customer_date: date and time when the order was delivered to the customer
   
    h. order_estimated_delivery_date: the estimated date when the order is expected to be 
    
</details>
   
<details>
  <summary> 4. olist_order_items_dataset.csv: </summary>
  
    a. order_id: unique identifier for the order
   
    b. order_item_id: unique identifier for each item within an order
   
    c. product_id: unique identifier for the product being ordered
   
    d. seller_id: unique identifier for the seller who listed the product
   
    e. shipping_limit_date: date and time when the seller has to ship the product price: the price of the product
   
    f. freight_value: shipping fee for the product
</details>

<details>
  <summary> 5. olist_order_payments_dataset.csv: </summary>
    
    a. order_id: unique identifier for the order
   
    b. payment_sequential: index number for each payment made for an order
   
    c. payment_type: type of payment used for the order (e.g. credit card, debit card, voucher)
   
    d. payment_installments: number of installments in which the payment was made
   
    e. payment_value: the value of the payment made
</details>
   
<details>
  <summary> 6. olist_products_dataset.csv: </summary>
    
    a. product_id: unique identifier for each product
    
    b. product_category_name: name of the category that the product belongs to
    
    c. product_name_lenght: number of characters in the product name
    
    d. product_description_lenght: number of characters in the product description
    
    e. product_photos_qty: number of photos for the product
    
    f. product_weight_g: weight of the product in grams
    
    g. product_length_cm: length of the product in centimeters
    
    h. product_height_cm: height of the product in centimeters
    
    i. product_width_cm: width of the product in centimeters
</details>
    
<details>
  <summary> 7. olist_sellers_dataset.csv: </summary>
  
    a. seller_id: unique identifier for each seller
   
    b. seller_zip_code_prefix: zip code prefix for the seller’s location
   
    c. seller_city: the city where the seller is located
   
    d. seller_state: state where the seller is located
</details>
   
<details>
  <summary> 8. product_category_name_translation.csv: </summary>
   
    a. product_category_name: name of the product category in Portuguese
 
    b. product_category_name_english: name of the product category in English

</details>

<details>
  <summary> 9. olist_order_reviews_dataset.csv: </summary>
  
    a. review_id: unique identifier for each review
    
    b. order_id: unique identifier for the order that the review is associated with
    
    c. review_score: numerical score (1–5) given by the customer for the product_review_comment_title: title          of the review comment
    
    d. review_comment_message: text of the review comment
    
    e. review_creation_date: date and time when the review was created
    
    f. review_answer_timestamp: date and time when the seller responded to the review (if applicable)
</details>
  
# 2. Project Stages

# 2.1 Entity Relationship diagram (ERD) Creation

![image](https://github.com/israkhaled1109/Advanced-SQL-E-Commerce-Database-Project-using-Olist-Database/assets/171425036/0fc08cae-9454-4553-8415-06451caad022)

# 2.2 Mapping and Normalization

![image](https://github.com/israkhaled1109/Advanced-SQL-E-Commerce-Database-Project-using-Olist-Database/assets/171425036/588e1cdc-45e9-45a9-b5e5-b6325ea12873)


# 2.3 Data Cleansing

During our exploration of the dataset, several elements were identified that could hinder effective analysis due to redundancy and lack of relevance. These elements include:

1- Null Values

2- Not Needed Columns

3- Repeated Columns

4- Important Missing Values

Below are samples of what we used to handle each of them:

For the null values, we replaced them with No Data

![image](https://github.com/israkhaled1109/Advanced-SQL-E-Commerce-Database-Project-using-Olist-Database/assets/171425036/8952e3d9-674f-4042-870d-ecaad8efb2db)

For the not needed columns, we deleted them from thier tables (the 4 columns title, message, creation_date and answer_timestamp were not needed in our project)

![image](https://github.com/israkhaled1109/Advanced-SQL-E-Commerce-Database-Project-using-Olist-Database/assets/171425036/5612d7c9-8322-4d26-9526-1b107ec5b45a)

For the repeated columns, we had the location details (city, state and zip_code) repeated for both customer and seller tables so, we created a new table named region, added all the need location details in it and related between it and the other tables with an FK

![image](https://github.com/israkhaled1109/Advanced-SQL-E-Commerce-Database-Project-using-Olist-Database/assets/171425036/94df102c-54df-4f91-9c1e-c5896e7aa125)
![image](https://github.com/israkhaled1109/Advanced-SQL-E-Commerce-Database-Project-using-Olist-Database/assets/171425036/e4a7c6ac-aaaa-4f63-9c51-aa2ebd7257dc)

Also, the product catogry name table had two columns: product_category_name and its translation. The product_category_name column is already in the olist_product table so we moved the product_category_name_english column in the product table as well and by this, the product category name table became no longer needed

![image](https://github.com/israkhaled1109/Advanced-SQL-E-Commerce-Database-Project-using-Olist-Database/assets/171425036/7cf0dea2-0964-42c8-b4ac-5411ad583b5c)

For the important missing values, we added them maintaining the data integrity

![image](https://github.com/israkhaled1109/Advanced-SQL-E-Commerce-Database-Project-using-Olist-Database/assets/171425036/73231804-0ddb-4c98-96ea-45039a9ece37)

# 2.4 Physical Schema Creation

![image](https://github.com/israkhaled1109/Advanced-SQL-E-Commerce-Database-Project-using-Olist-Database/assets/171425036/5e476357-eee5-47d4-a4c6-f8e33add0943)



# 2.5 Data Analysis

In this stage, we used SQL to answer business questions and manipulate data in a way that serve the business, all the questions are below and all the queries are in 'DataAnalysis.sql' file:

1- What is the distribution of seller ratings on Olist, and how does this impact sales performance?

2- How many customers have made repeat purchases on Olist?

3- What is the average customer rating for products sold on Olist, and how does this impact sales performance?

4- What are the top 10 popular product categories on Olist, and what are their sales volumes?

5- What is the average order value (AOV) on Olist, and how does this vary by product category?

6-What are best sellers based on some criteria (on last number of days, number of products the seller lists for sale, number of orders sold, and average scores of orders?

7-What are the number of products sold by category and city?

8-What are the best customers by revenue?

9- What is the total revenue generated by Olist,  how is revenue changed over time?

10- What is the average order cancellation rate on Olist?

11- Create view to show Which product categories have the highest profit margins on Olist, and how can the company increase 
profitability across different categories?

12- Create trigger to prevent any one to update or change price on table olist_order_items and return  
username , ModifiedDate and old value and newvalue of price

13- Create trigger to prevent any one to update or change payment value on table olist_order_payments
and return username, ModifiedDate and old value and newvalue

14- Create a function to check average reviews of a category name for a chosen name














