profile=$1
list=`aws secretsmanager list-secrets --profile $profile --region us-east-2   --query  'SecretList[].Name' --output text`
for i in $list
do
  dt=`aws secretsmanager describe-secret --secret-id $i --profile $profile --region us-east-2 --query 'LastAccessedDate' --output text`
  echo "$i  $dt"
done
