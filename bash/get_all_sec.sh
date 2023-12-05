PROFILE=$1
REGION=$2
#aws ec2 describe-security-groups --query 'SecurityGroups[*].GroupId' --profile $PROFILE --region $REGION  --output text | tr '\t' '\n'
#aws ec2 describe-instances --query 'Reservations[*].Instances[*].SecurityGroups[*].GroupId' --output text | tr '\t' '\n' | sort | uniq

comm -23  <(aws ec2 describe-security-groups --profile $PROFILE --region $REGION --query 'SecurityGroups[*].GroupId'  --output text | tr '\t' '\n'| sort) <(aws ec2 describe-instances  --profile $PROFILE --region $REGION --query 'Reservations[*].Instances[*].SecurityGroups[*].GroupId' --output text | tr '\t' '\n' | sort | uniq)
