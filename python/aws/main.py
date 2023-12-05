## This is a sample Python script.
# import boto3
#
#
## Press ⌃R to execute it or replace it with your code.
## Press Double ⇧ to search everywhere for classes, files, tool windows, actions, and settings.
# def print_hi(name):
#    # Use a breakpoint in the code line below to debug your script.
#    print(f"Hi, {name}")  # Press ⌘F8 to toggle the breakpoint.
#
#
regions = ["us-east-1" "us-east-2"]
profiles = [
    "authess-nonprod",
    "authess-prod",
    "authess-backup",
    "learningObjects-nonprod",
    "learningObjects-prod",
    "evolve-dev",
    "evolve-prod",
    "evolve-backup",
    #    "elsevieradvantage-nonprod",
    #    "elsevieradvantage-prod",
    #    "elsevieradvantage-backup",
    #    "elsevier360-nonprod",
    #    "elsevier360-prod",
    #    "elsevier360-backup",
    #    "contenthub-prod",
    #    "eols-nonprod",
    #    "eols-prod",
    #    "eols-backup",
    #    "authoring-nonprod",
    #    "authoring-prod",
    #    "authoring-backup",
    #    "hesi-nonprod",
    #    "hesi-prod",
    #    "hesi-backup",
    #    "shadowhealth-nonprod",
    #    "shadowhealth-prod",
    #    "shadowhealth-backup",
    #    "sysadmins",
    #    "simoffice-original",
    #    "simoffice-backup",
]
## Press the green button in the gutter to run the script.
# if __name__ == "__main__":
#    print_hi("PyCharm")
#
## See PyCharm help at https://www.jetbrains.com/help/pycharm/

import boto3

response = {}
for profile in profiles:
    boto3.setup_default_session(profile_name=profile, region_name="us-east-1")
    client = boto3.client("ec2")

    # Initialize the response dictionary

    # Create an EC2 client

    # Describe instances and store the response in the dictionary
    response[profile] = client.describe_instances()

    # Now you can access the response as needed

instances = {}
for profile in profiles:
    instances[profile] = []
    for k, v in response[profile].items():
        if k == "Reservations" and len(v) > 0:
            for i in v:
                # print(f"{profile} --> {i['Instances'][0]}")
                instances[profile].append(i["Instances"][0])

for profile in profiles:
    if len(instances[profile]) != 0:
        for instance in instances[profile]:
            count = 1
            for i in instance['Tags']:
                print(f"{instance['InstanceId']}: {i['Key']} --> {i['Value']}")
                if i['Key'] == 'Orchestration':
                    print(f"{i['Value']}  {instance['InstanceId']}")
                count += 1
    else:
        print(f"No instances found in {profile}")
