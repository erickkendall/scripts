username="$1"
vpcid="$2"
myip="$3"
profile="$4"

secgroup=`aws ec2 create-security-group --group-name "$username-ssh-access" --description "SSH access for $username" --vpc-id $vpcid --profile $profile --region us-east-1 --output text`

echo "$secgroup"

aws ec2 authorize-security-group-ingress \
              --group-id $secgroup \
              --protocol tcp \
              --port 22 \
              --cidr "$myip/32" \
              --profile $profile
