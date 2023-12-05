import boto3
import pandas as pd

#pd.set_option('display.max_columns', None)  # Show all columns
#pd.set_option('display.max_colwidth', None)

profiles = [
    "authess-nonprod",
    "authess-prod",
    "authess-backup",
    "learningObjects-nonprod",
    "learningObjects-prod",
    "evolve-dev",
    "evolve-prod",
    "evolve-backup",
    "elsevieradvantage-nonprod",
    "elsevieradvantage-prod",
    "elsevieradvantage-backup",
    "elsevier360-nonprod",
    "elsevier360-prod",
    "elsevier360-backup",
    "contenthub-prod",
    "eols-nonprod",
    "eols-prod",
    "eols-backup",
    "authoring-nonprod",
    "authoring-prod",
    "authoring-backup",
    "hesi-nonprod",
    "hesi-prod",
    "hesi-backup",
    "shadowhealth-nonprod",
    "shadowhealth-prod",
    "shadowhealth-backup",
    "sysadmins",
    "simoffice-original",
    "simoffice-backup",
]

columns_to_include = [
  "InstanceId",
  "InstanceType",
  "KeyName",
  "State.Name",
  "PrivateIpAddress",
  "Tags",
]

instances=[]
all=[]
for profile in profiles:
  for region in 'us-east-1', 'us-east-2':
  
      print(f"{profile} -- {region}")
      # Set up the AWS session and client
      boto3.setup_default_session(profile_name=profile, region_name=region)
      ec2_client = boto3.client("ec2")
  
      # Describe EC2 instances
      response = ec2_client.describe_instances()
  
      # Extract and flatten the instance data
      for reservation in response["Reservations"]:
          for instance in reservation["Instances"]:
              instances.append(instance)

          # if there instances in the account
          if len(instances) > 0:
            df = pd.json_normalize(instances) 
            df = df[columns_to_include]
            df['Profile']=profile
            df['Region']=region
            all.append(df)

print(all)
