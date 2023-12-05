all_profiles=("authess-backup" "authess-nonprod" "authess-prod" "authoring-backup" "authoring-nonprod" "authoring-prod" "contenthub-prod" "elsevieradvantage-backup" "elsevieradvantage-nonprod" "elsevieradvantage-prod" "eols-backup" "eols-nonprod" "eols-prod" "evolve-prod" "hesi-backup" "hesi-nonprod" "hesi-prod" "learningObjects-prod" "shadowhealth-nonprod" "simoffice-backup" "simoffice-nonprod" "simoffice-original" "sysadmins")


# account=$1
for account in "${all_profiles[@]}"
do
  for i in `aws s3 ls  --profile $account | awk '{ print $3 }'`
  do
    echo "$account $i"
    aws s3api get-bucket-logging --bucket $i --profile $account --query 'LoggingEnabled.TargetBucket' --output text
	done
  done
done
