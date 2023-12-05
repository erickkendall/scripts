import boto3
import pandas as pd

pd.set_option('display.max_columns', None)  # Show all columns
pd.set_option('display.max_colwidth', None)

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


# create a DataFrame
df = pd.DataFrame(columns=['ELB', 'Instances', 'Account', 'Region'])

count=0   # loc counter for DataFrame

for profile in profiles:
  for region in "us-east-1", "us-east-2":

    boto3.setup_default_session(profile_name=profile, region_name=region)
    elb_client = boto3.client("elbv2")
    
    # Describe ELB(s)
    response = elb_client.describe_load_balancers()
    
    # Information on all ELB(s)
    elbs=response['LoadBalancers']
    
    
    
    for i in elbs:
      elb_name = (f"{i['LoadBalancerName']}")
    
      # Describe Target Groups
      response = elb_client.describe_target_groups(LoadBalancerArn=i['LoadBalancerArn'])
    
      # Traverse all Target Groups
      for tg in response['TargetGroups']:
        all_instances=[]
    
        
        response = elb_client.describe_target_health( TargetGroupArn=tg['TargetGroupArn'])

        for x in response['TargetHealthDescriptions']:
          if x['Target']['Id'].startswith('i'):
            instance = x['Target']['Id']
            all_instances.append(instance)
        if len(all_instances) > 0:
          df.loc[count] = [elb_name, profile, region, ", ".join(all_instances).replace('"', '')]
          print(f"{count} {elb_name} {all_instances} {profile} {region}")
        count+=1
df.to_csv('elbs.csv',index=False)
