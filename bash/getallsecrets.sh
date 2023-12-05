#!/bin/sh

#usage () {
#  # check whether user had supplied AWS account profile -h or --help . If yes display usage
#  if [[ ( $@ == "--help") ||  $@ == "-h" ]]
#  then
#  	echo "Usage: $0 [AWS profile]"
#    exit 1
#  else
#    echo "Getting secrets"
#  fi
#}
#  
#get_secrets () {

# AWS profile (required)
PROFILE=$1
REGION=$2

# Get AWS account number 
AWS_ACCOUNT=`aws sts get-caller-identity --profile $PROFILE --query 'Account' --output text`

# Get a list of all secrets in the AWS account
SECRETS_LIST=`aws secretsmanager list-secrets --profile $PROFILE --region $REGION --query 'SecretList[?contains(Name, \`ssh\`)==\`true\`].Name' --output text`
# SECRETS_LIST=`aws secretsmanager list-secrets --profile $PROFILE --region $REGION --query 'SecretList[].Name' --output text`

for secret in $SECRETS_LIST
do
  echo "$secret"
  # create directory for keyfile 
  key_dir=`dirname $AWS_ACCOUNT/$secret`
  mkdir -p /tmp/$key_dir

  # extract secret string and save to file
  aws secretsmanager get-secret-value --secret-id $secret --query 'SecretString' --profile $PROFILE --region $REGION | sed 's/\\n/\n/g' | sed 's/[$"|^"]//' > /tmp/$key_dir/key

  # modify key permissions
  chmod 600 /tmp/$key_dir/key

  echo "Key file $key_dir/key created"
done
