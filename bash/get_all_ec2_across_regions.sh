#all_profiles=("authess-nonprod" "authess-prod" "authess-backup" "learningObjects-nonprod" "learningObjects-prod" "evolve-dev" "evolve-prod" "evolve-backup" "elsevieradvantage-nonprod" "elsevieradvantage-prod" "elsevieradvantage-backup" "elsevier360-nonprod" "elsevier360-prod" "elsevier360-backup" "contenthub-prod" "eols-nonprod" "eols-prod" "eols-backup" "authoring-nonprod" "authoring-prod" "authoring-backup" "hesi-nonprod" "hesi-prod" "hesi-backup" "shadowhealth-nonprod" "shadowhealth-prod" "shadowhealth-backup" "sysadmins" "simoffice-original" "simoffice-nonprod" "simoffice-backup")
all_profiles=("authoring-backup" "hesi-nonprod" "hesi-prod" "hesi-backup" "shadowhealth-nonprod" "shadowhealth-prod" "shadowhealth-backup" "sysadmins" "simoffice-original" "simoffice-nonprod" "simoffice-backup")

# account=$1
for account in "${all_profiles[@]}"
do
  echo $account
  region_list=`aws ec2 describe-regions --profile $account --query 'Regions[].RegionName' --output text`
  for reg in $region_list
  do
    echo "$reg instances" >> log.$account 2>&1
    # aws ec2 describe-instances --profile $account --region $reg  --filters Name=instance-state-name,Values=running --query "Reservations[*].Instances[*].InstanceId" --output text  >> log.$account 2>&1
    aws ec2 describe-instances --profile $account --region $reg  --filters Name=instance-state-name,Values=running --query 'Reservations[*].Instances[*].[InstanceId,PlatformDetails,Tags[?Key==`Name`] | [0].Value][] | sort_by(@, &[1])'  --output table > ./out-files/$account.$reg.out

    # echo "$reg flow logs"
    # aws ec2 describe-flow-logs --profile $account --region $reg
  done
done
