import boto3
import pandas as pd

#pd.set_option('display.max_columns', None)  # Show all columns
#pd.set_option('display.max_colwidth', None)  # Show entire content of each cell without truncation

def filter_and_print_values(data_frame, keys_to_filter):
    filtered_df = data_frame[data_frame['Key'].isin(keys_to_filter)]


# List of AWS profiles to iterate through
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

# List of keys to filter for
keys_to_filter = ['Name']

for profile in profiles:
    print(f"Profile: {profile}")
    
    columns_to_include = [
        'InstanceId',
        'InstanceType',
        'KeyName',
        'State.Name',
        'PrivateIpAddress',
		'Tags',
    ]
    
    # Set up the AWS session and client for the current profile
    boto3.setup_default_session(profile_name=profile, region_name="us-east-1")
    ec2_client = boto3.client("ec2")
    
    # Describe EC2 instances
    response = ec2_client.describe_instances()
    
    # Extract and flatten the instance data
    instances = []
    for reservation in response['Reservations']:
        for instance in reservation['Instances']:
            instances.append(instance)
    
    if len(instances) > 0:
        try:
            # Create a Pandas DataFrame from the instance data
            df = pd.json_normalize(instances)
            df = df[columns_to_include]
            
            # Filter the DataFrame based on keys_to_filter
            #filtered_df = df[df['Tags'].str.contains('|'.join(keys_to_filter), case=False, na=False)]
            #filtered_df = df[df['Tags'].apply(lambda tags: any(tag['Key'] in keys_to_filter for tag in tags))]
            filtered_df=filter_and_print_values(df, keys_to_filter)


            
            # Print or perform further actions with the filtered DataFrame
            if not filtered_df.empty:
                print(f"Filtered DataFrame for {profile}:")
                print(df)
            # You can perform additional operations on the filtered DataFrame for this profile here
            # For example, save it to a file, analyze the data, etc.
            else:
                print(f"No data for keys_to_filter in {profile}")
            
            # You can perform additional operations on the filtered DataFrame for this profile here
            # For example, save it to a file, analyze the data, etc.
        except Exception as e:
            print(f"An error occurred for profile {profile}: {str(e)}")
    else:
        print(f"No instances found for profile {profile}")



