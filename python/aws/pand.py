import boto3
import pandas as pd

boto3.setup_default_session(profile_name="authoring-nonprod", region_name="us-east-2")
client = boto3.client("ec2")
response = client.describe_instances()
lst = []
for i in response["Reservations"]:
    print(i["Instances"][0])
    lst.append(i["Instances"][0])

print(lst[0])
