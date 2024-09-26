# Databricks notebook source
from pyspark.sql import functions as F
from pyspark.sql import Window
from config import get_currency_path

# COMMAND ----------

dbutils.widgets.text("env", "test", "")
env = dbutils.widgets.get("env")
currency_source_path, currency_target_path, currency_checkpoint = get_currency_path(env)

# COMMAND ----------

# Step 1 : Read the currency data in bulk
currency_bulk_df = (
    spark.read
        .format("delta")  
        .load(currency_source_path)
        .select(
                F.to_date(F.col('dt'), "yyyy-MM-dd").alias("date") 
                ,F.col("data")
                )
)

# COMMAND ----------

# Step 2: Extract the day of the week 
currency_bulk_df = currency_bulk_df.withColumn("day_of_week", F.date_format(F.col("date"), "EEEE"))

# Step 3: Filter for Fridays
friday_df = currency_bulk_df.filter(F.col("day_of_week") == "Friday").drop("day_of_week")  # Drop day_of_week from Friday data to avoid conflict

# Step 4: Get Min and Max dates
min_date = currency_bulk_df.agg(F.min("date").alias("min_date")).collect()[0]["min_date"]
max_date = currency_bulk_df.agg(F.max("date").alias("max_date")).collect()[0]["max_date"]

# Generate a DataFrame with all dates between min and max date (including weekends)
date_range_df = spark.sql(f"SELECT explode(sequence(to_date('{min_date}'), to_date('{max_date}'), interval 1 day)) as date")

# Step 5: Identify missing dates (Saturdays and Sundays) not present in Delta data
existing_dates_df = currency_bulk_df.select("date").distinct()
missing_dates_df = date_range_df.join(existing_dates_df, "date", "leftanti")

# Step 6: Identify missing Saturdays and Sundays
missing_weekends_df = missing_dates_df.withColumn("day_of_week", F.date_format(F.col("date"), "EEEE")) \
                                      .filter((F.col("day_of_week") == "Saturday") | (F.col("day_of_week") == "Sunday"))

# Step 7: Find the corresponding Friday's data for each missing weekend date
weekend_filled_df = missing_weekends_df \
    .withColumn("related_friday", F.date_sub(F.col("date"), F.when(F.col("day_of_week") == "Saturday", 1).otherwise(2))) \
    .join(friday_df.withColumnRenamed("date", "friday_date"), F.col("related_friday") == F.col("friday_date"), "left") \
    .drop("related_friday", "day_of_week", "friday_date")  


# Step 8: Drop unnecessary col from the main df and Combine the original data and the new weekend data
currency_bulk_df = currency_bulk_df.drop('day_of_week')
final_df = currency_bulk_df.unionByName(weekend_filled_df)

# COMMAND ----------

# final_df.orderBy(F.col('date').desc()).display()

# COMMAND ----------

# Write the filtered data to a Delta table
final_df.write.format("delta") \
    .mode("overwrite")  \
    .option("path", currency_target_path) \
    .save()
