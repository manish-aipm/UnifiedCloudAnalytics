-- Amazon provided free data on Snowflake Marketplace for Data analysis

select * from AMAZON_AND_ECOMMERCE_WEBSITES_PRODUCT_VIEWS_AND_PURCHASES.DATAFEEDS.PRODUCT_VIEWS_AND_PURCHASES limit 10;

select year,month,product,title,brand,estimated_views,estimated_purchasesSAP_PROJECT.RAW_DATA.PRODUCT_REVIEWS from AMAZON_AND_ECOMMERCE_WEBSITES_PRODUCT_VIEWS_AND_PURCHASES.DATAFEEDS.PRODUCT_VIEWS_AND_PURCHASES
where sub_category = 'Automotive - Tires & Wheels';