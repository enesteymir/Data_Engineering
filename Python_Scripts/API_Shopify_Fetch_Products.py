# Databricks notebook source
pip install --upgrade ShopifyAPI --quiet

# COMMAND ----------

import shopify
import requests
import time
import json
from datetime import datetime

# COMMAND ----------

# these credentials are retrieved from the Shopify > Settings > Apps and sales channels > Develop apps
# the URL : https://admin.shopify.com/store/{SHOP_NAME}/settings/apps/development
SHOP_NAME = 'x....u'
API_KEY = '65c...........81'
API_SECRET_KEY = 'cd8.............f3'
API_ACCESS_TOKEN = 'shpat_23c............a919d'
API_VERSION = "2025-07"

# COMMAND ----------


BASE_URL = f"https://{SHOP_NAME}.myshopify.com/admin/api/{API_VERSION}"

headers = {
    "X-Shopify-Access-Token": API_ACCESS_TOKEN,
    "Content-Type": "application/json"
}

TARGET_PATH = "dbfs:/mnt/shopify/"
RATE_LIMIT_DELAY = 0.5   

def safe_get(url):
    """GET request with retry on 429"""
    while True:
        resp = requests.get(url, headers=headers)
        if resp.status_code == 429:
            retry_after = int(resp.headers.get("Retry-After", 2))
            print(f"Rate limited. Waiting {retry_after}s...")
            time.sleep(retry_after)
            continue
        resp.raise_for_status()
        return resp

def fetch_products_in_batches():
    """Fetch all products + metafields and write each batch into separate JSON file"""
    updated_date = datetime.utcnow().strftime("%Y-%m-%d")
    page_num = 0
    endpoint = f"{BASE_URL}/products.json?limit=250"

    while endpoint:
        response = safe_get(endpoint)
        data = response.json()
        products = data.get("products", [])

        # Fetch metafields for each product
        for product in products:
            mf_url = f"{BASE_URL}/products/{product['id']}/metafields.json"
            mf_response = safe_get(mf_url)
            product["metafields"] = mf_response.json().get("metafields", [])
            time.sleep(RATE_LIMIT_DELAY)

        # Write batch to separate JSON file
        path = f"{TARGET_PATH}shopify__{updated_date}__{page_num}.json"
        dbutils.fs.put(path, json.dumps(products, indent=2), overwrite=True)
        print(f"Wrote {len(products)} products to {path}")
        page_num += 1

        # Pagination: use the Link header properly
        link_header = response.headers.get("Link")
        if link_header and 'rel="next"' in link_header:
            # Extract the next page URL from <...>; rel="next"
            next_url = [part.split(";")[0].strip("<> ") for part in link_header.split(",") if 'rel="next"' in part][0]
            endpoint = next_url
        else:
            endpoint = None

    print("🎉 Finished fetching all products")

# COMMAND ----------

containerName = "shopify"
storageAccountName = "blobexternals"
sas = "?sv=2023-01-03&st=2025-06-09T00................6Ea%2FU1s%3D"
config = "fs.azure.sas." + containerName+ "." + storageAccountName + ".blob.core.windows.net"

try:
    dbutils.fs.unmount("/mnt/shopify")
except:
    pass
    
try:
    dbutils.fs.mount(
      source = "wasbs://{}@{}.blob.core.windows.net".format(containerName,storageAccountName),
      mount_point = "/mnt/shopify",
      extra_configs = {config : sas})
except:
    pass

# COMMAND ----------

# Run and write to blob
fetch_products_in_batches()
