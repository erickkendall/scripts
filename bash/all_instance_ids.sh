for region in "us-east-1" "us-east-2"
do
  for profile in "${profile[@]}"
  do
    all=`aws ec2 describe-instances --profile $profile --region $region --query 'Reservations[].Instances[].InstanceId' --output text`
	for i in $all
	do
	  echo "$i,$profile,$region"
	done
  done
done
