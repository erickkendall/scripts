elbv2list=`aws elbv2 describe-load-balancers --profile simoffice-original --region us-east-1 --query 'LoadBalancers[].LoadBalancerArn' --output text`
echo $elbv2list

for i in $elbv2list
do
  echo $i
  tgs=`aws elbv2 describe-listeners --load-balancer-arn $i --profile simoffice-original --region us-east-1 --query 'Listeners[].DefaultActions[].ForwardConfig[].TargetGroups[].TargetGroupArn' --output text`
  for j in $tgs:
  do
      aws elbv2 describe-target-health --target-group-arn ${j} --profile simoffice-original --region us-east-1  --query 'TargetHealthDescriptions[*].Target.Id'
  done
done
