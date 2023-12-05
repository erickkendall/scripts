profile=$1
for i in `aws ec2 describe-security-groups --profile $profile --region us-east-1 --query 'SecurityGroups[].GroupId' --output text`
do
  echo $i
  aws ec2 describe-security-group-rules --filters Name="group-id",Values="$i" --profile $profile --region us-east-1
done
