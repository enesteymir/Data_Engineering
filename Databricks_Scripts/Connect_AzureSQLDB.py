# Databricks notebook source
# In the settings of Azure SQL Server > Networking, it should be clicked "allow azure services to access this server" at the bottom of the page.
# If databricks is not used in Azure, then Dtabricks's Client IP should be added to allowed IPs in firewall settings.

# COMMAND ----------

# MAGIC %md
# MAGIC ### Connect to Azure SQL DB
# MAGIC #### PySpark - First Way 

# COMMAND ----------

HostName = "reporting.database.windows.net"
Port     = 2033
Database = "dwh_reporting"
UserName = "eadmin"
Password = "xxxxxxx"
Driver   = "com.microsoft.sqlserver.jdbc.SQLServerDriver"

jdbcUrl = f"jdbc:sqlserver://{HostName}:{Port};databaseName={Database};user={UserName};password={Password}"

# COMMAND ----------

# read the table from the db
df = spark.read.format("jdbc").option("url",jdbcUrl).option("dbtable","table_name_here").load()
display(df)

# COMMAND ----------

# MAGIC %md
# MAGIC #### PySpark - Second Way

# COMMAND ----------

# In Azure SQL Server > DB > Connecion Strings : Show database connection strings > Choose related driver : JDBC and copy it and write the db password
connection_string = "jdbc:sqlserver://reporting.database.windows.net:2033;database=dwh_reporting;user=eadmin@reporting;password=xxxxx;encrypt=true;trustServerCertificate=false;hostNameInCertificate=*.database.windows.net;loginTimeout=30;"

# COMMAND ----------

# read directly from table
df = spark.read.jdbc(connection_string,"table_name_here")
display(df)

# COMMAND ----------

# read by query
query = f"""
(
    SELECT DISTINCT order_id 
    FROM logistics_ft_orders 
    WHERE purchase_date >= '{start}' AND purchase_date <= '{end}'
) AS orders_filtered
"""

df_orders = spark.read.jdbc(
    url=connection_string,
    table=query
)