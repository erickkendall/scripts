instance_list=`aws ec2 describe-instances --region us-east-1 --profile simoffice-original --query 'Reservations[*].Instances[].[Tags[?Key==\`Name\`].Value | join(\`, \`, @), InstanceId,PrivateIpAddress,KeyName,Platform  |  join(\`, \`, to_array(to_string(@))) ]' --output table  | grep windows | cut -d"|" -f3`


for instance in $instance_list
do
#    aws ec2 get-password-data --instance-id $instance --profile simoffice-original --priv-launch-key  ~/Desktop/mywork/el-2567-tanium/SimulationsNonProd.pem --output table
    aws ec2 get-password-data --instance-id $instance --profile simoffice-original --priv-launch-key  ~/Desktop/mywork/el-2567-tanium/SimulationsProd.pem --output table
done
