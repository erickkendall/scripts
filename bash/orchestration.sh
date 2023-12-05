accounts=("authess-nonprod" "authess-prod" "authess-backup" "learningObjects-nonprod" "learningObjects-prod" "evolve-dev" "evolve-prod" "evolve-backup" "elsevieradvantage-nonprod" "elsevieradvantage-prod" "elsevieradvantage-backup" "elsevier360-nonprod" "elsevier360-prod" "elsevier360-backup" "contenthub-prod" "eols-nonprod" "eols-prod" "eols-backup" "authoring-nonprod" "authoring-prod" "authoring-backup" "hesi-nonprod" "hesi-prod" "hesi-backup" "shadowhealth-nonprod" "shadowhealth-prod" "shadowhealth-backup" "sysadmins" "simoffice-original" "simoffice-backup")


# regions=("ap-northeast-1" "ap-northeast-2" "ap-northeast-3" "ap-south-1" "ap-southeast-1" "ap-southeast-2" "ca-central-1" "eu-central-1" "eu-north-1" "eu-west-1" "eu-west-2" "eu-west-3" "sa-east-1" "us-east-1" "us-east-2" "us-west-1" "us-west-2")
regions=("us-east-1" "us-east-2")

for acct in "${accounts[@]}"
do
  for reg in "${regions[@]}"
  do 
    AWS_ACCOUNT=`aws sts get-caller-identity --profile $acct --query 'Account' --output text`
    echo "$AWS_ACCOUNT $acct $reg " > ./orch/$acct.$reg
    # Has Orchestration or orchestration tag
    aws ec2 --profile $acct --region $reg  describe-instances --filters "Name=tag-key,Values=Orchestration" --query 'Reservations[].Instances[].[Tags[?Key==`Name`].Value | join(`, `, @), InstanceId |  join(`, `, to_array(to_string(@))) ]' --output table >> ./orch/$acct.$reg
    echo "break" >> ./orch/$acct.$reg
    aws ec2 describe-instances --profile eols-prod --region us-east-1  --query 'Reservations[].Instances[?!contains(Tags[].Key, `Orchestration`)][].[Tags[?Key==`Name`].Value | join(`, `, @), InstanceId |  join(`, `, to_array(to_string(@))) ]' --output table >> ./orch/$acct.$reg
  done
done

