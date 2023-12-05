for acct in `cat all-accounts.txt`
do
  for reg in `cat all-regions.txt`
  do
      echo "$acct $reg"
	  aws ec2 describe-instances --profile $acct --region $reg
  done
done
