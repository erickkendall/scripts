for region in "us-east-1" "us-east-2"
do
  for profile in "${profile[@]}"
  do
    echo "$profile $region"
    all=`aws ec2 describe-instances --profile $profile --region $region --query 'Reservations[].Instances[].BlockDeviceMappings[].Ebs.VolumeId' --output text`
	aws ec2 --volume-ids describe-volumes $all --filters Name=encrypted,Values=false --query Volumes[].VolumeId --profile $profile --region $region --output text
  done
done
