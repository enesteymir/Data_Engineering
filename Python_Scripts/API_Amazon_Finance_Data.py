# Databricks notebook source
from time import sleep
import requests
import re
import json
import datetime
from requests_aws4auth import AWS4Auth
import urllib
from aws_requests_auth.aws_auth import AWSRequestsAuth

dbutils.widgets.text('start', '')
dbutils.widgets.text('end', '')
dbutils.widgets.text('channel', '')

start = dbutils.widgets.get('start')
end = dbutils.widgets.get('end')
channel =  dbutils.widgets.get('channel')

# IAM User ebzspapireporting
A_KEY = 'AKI............URR6N'
A_SECRET = 'g6....................V'
ARN = 'arn:aws:iam::46.....117:role/SellingPartnerApiRole'


containerName = "amazon-finance-api"


if channel == 'Companyname':
    C_KEY = 'amzn1.application-oa2-client.5cc.................00'
    C_SECRET_KEY = 'amzn1.oa2-cs.v1.bab2..................f0ae361'
    C_REFRESH_TOKEN = 'Atzr|IwEBIOGQz.................................Y'

# COMMAND ----------

def get_datetime():
    return datetime.datetime.utcnow().strftime("%Y%m%dT%H%M%SZ")


def get_access_token():
    global C_KEY, C_SECRET_KEY, C_REFRESH_TOKEN
    r = requests.post(f"https://api.amazon.com/auth/o2/token", data={
                        "grant_type":"refresh_token",
                        "refresh_token":C_REFRESH_TOKEN,
                        "client_id": C_KEY,
                        "client_secret": C_SECRET_KEY
                        })

    # print(r.json())

    return r.json()['access_token']





def assume_role():
    r = requests.get(f"https://sts.amazonaws.com?Version=2011-06-15&Action=AssumeRole&RoleSessionName=Test&RoleArn={ARN}&DurationSeconds=3600",
                    auth=AWS4Auth(A_KEY, A_SECRET, 'us-east-1', 'sts'))

    return (re.findall('<AccessKeyId>(.+)</AccessKeyId>', r.text)[0], re.findall('<SecretAccessKey>(.+)</SecretAccessKey>', r.text)[0], re.findall('<SessionToken>(.+)</SessionToken>', r.text)[0])





def g(rel_url):
    global access_token, access_key, secret_key, session_token

    r = requests.get(f"https://sellingpartnerapi-eu.amazon.com{rel_url}",
        headers={'x-amz-access-token': access_token, 'Content-Type': 'application/x-www-form-urlencoded'},
        auth=AWS4Auth(access_key, secret_key, 'eu-west-1', 'execute-api', session_token=session_token))

    # print(r.headers)

    return(r.json())


def g2(rel_url):
    global access_token, access_key, secret_key, session_token

    auth = AWSRequestsAuth(aws_access_key = access_key,
                       aws_secret_access_key = secret_key,
                       aws_host='sellingpartnerapi-eu.amazon.com',
                       aws_region='eu-west-1',
                       aws_token = session_token,
                       aws_service='execute-api')

    r = requests.get(f"https://sellingpartnerapi-eu.amazon.com{rel_url}",
        headers={'x-amz-access-token': access_token, 'Content-Type': 'application/x-www-form-urlencoded'},
        auth=auth)

    # print(r.headers)

    return(r.json())




def gg(rel_url, params):
    global access_token, access_key, secret_key, session_token

    r = requests.get(f"https://sellingpartnerapi-eu.amazon.com{rel_url}",
        params=params,
        headers={'x-amz-access-token': access_token, 'Content-Type': 'application/x-www-form-urlencoded'},
        auth=AWS4Auth(access_key, secret_key, 'eu-west-1', 'execute-api', session_token=session_token))

    return(r.json())



def get_keys():
    print('Getting Keys...')
    return get_access_token(), *assume_role()

  
    
access_token, access_key, secret_key, session_token = get_keys()
print('Got Keys!')



def fin(nextToken, idx, start=None, end=None, fileName=None):

    r = None
    if nextToken is None:
        r = gg('/finances/v0/financialEvents', {
            'PostedAfter': start,
            'PostedBefore': end
        })
    else:
        r = g2('/finances/v0/financialEvents?NextToken=' + nextToken)
        
    
    print('dbfs:/mnt/' + containerName + '/' + f'{fileName}__{idx}.json')
    dbutils.fs.put('dbfs:/mnt/' + containerName + '/' + f'{channel}__{fileName}__{idx}.json', json.dumps(r, indent=4), overwrite = True)

    print('Done: ', idx)
    sleep(2)
    try:
        return (r["payload"]["NextToken"])
    except:
        return None


    
    
def download_fin(start , end, fileName):
    global access_token, access_key, secret_key, session_token
    
    i, t = 1, fin(None, 1, start, end, fileName)

    while t is not None:
        i+=1
        t = fin(urllib.parse.quote_plus(t), i, fileName=fileName)
        if i % 20 == 0:
            print('sleeping')
            sleep(30)
        if i % 150 == 0:
            print('Refreshing Keys...')
            access_token, access_key, secret_key, session_token = get_keys()
            print('Keys Refreshed!')

# COMMAND ----------

storageAccountName = "blobsaless"
sas = "?sv=2023-01-03&st=2023-12-20T............................2%2BU%3D"
config = "fs.azure.sas." + containerName+ "." + storageAccountName + ".blob.core.windows.net"
 
try:
    dbutils.fs.unmount("/mnt/" + containerName)
except:
    pass
    
try:
    dbutils.fs.mount(
    source = f"wasbs://{containerName}@{storageAccountName}.blob.core.windows.net",
    mount_point = "/mnt/" + containerName,
    extra_configs = {config : sas})
except:
     pass

# COMMAND ----------

download_fin(start, end, f"{start.replace(':', '_')}__{end.replace(':', '_')}")