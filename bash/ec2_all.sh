#for i in `cat ~/.aws/credentials | grep "^\[" | sed 's/[][]//g'`
#do 
#  echo $i
#  s3buckets[$i]=`aws s3 ls --profile $i`
#done



for i in ""
do
  region="us-east-2"
  if [[ "$i"=="authoring-nonprod" ]] || [[ "$i"=="authoring-prod" ]] || [[ "$i"=="authoring-backup" ]] 
  then
    region="us-east-2"
  fi
  aws ec2 describe-instances --profile $i --region $region --query 'Reservations[*].Instances[*].[LaunchTime,ImageId,PlatformDetails,Tags[?Key==`Name`] | [0].Value][] | sort_by(@, &[0])'  --output table

done
