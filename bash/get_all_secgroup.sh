all_profiles=("authess-nonprod" "authess-prod" "authess-backup" "learningObjects-nonprod" "learningObjects-prod" "evolve-dev" "evolve-prod" "evolve-backup" "elsevieradvantage-nonprod" "elsevieradvantage-prod" "elsevieradvantage-backup" "elsevier360-nonprod" "elsevier360-prod" "elsevier360-backup" "contenthub-prod" "eols-nonprod" "eols-prod" "eols-backup" "authoring-nonprod" "authoring-prod" "authoring-backup" "hesi-nonprod" "hesi-prod" "hesi-backup" "shadowhealth-nonprod" "shadowhealth-prod" "shadowhealth-backup" "sysadmins" "simoffice-original" "simoffice-nonprod" "simoffice-backup")


# account=$1
for account in "${all_profiles[@]}"
do
  for id in `aws ec2 describe-security-groups --profile eols-prod  --query "SecurityGroups[].GroupId" --output text`
  do
    echo "$account $id"
	aws ec2 describe-security-groups --profile $account
  done
done
