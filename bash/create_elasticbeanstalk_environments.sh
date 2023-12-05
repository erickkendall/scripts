profile=$1
regions=$2
my-cname=$3
my-app=$4

# Check if the CNAME for the environment is available.
aws elasticbeanstalk check-dns-availability --cname-prefix $my-cname --profile $profile --region $regions

# Make sure your application version exists.
aws elasticbeanstalk describe-application-versions --application-name $my-app --version-label $version --profile $profile --region $regions

# If you don't have an application version for your source yet, create it. For example, the following command creates an application version from a source bundle in Amazon Simple Storage Service (Amazon S3).
aws elasticbeanstalk create-application-version --application-name my-app --version-label v1 --source-bundle S3Bucket=DOC-EXAMPLE-BUCKET,S3Key=my-source-bundle.zip --profile $profile --region $regions

# Create a configuration template for the application.
aws elasticbeanstalk create-configuration-template --application-name my-app --template-name v1 --solution-stack-name "64bit Amazon Linux 2015.03 v2.0.0 running Ruby 2.2 (Passenger Standalone)"

# Create environment.
aws elasticbeanstalk create-environment --cname-prefix $my-cname --application-name my-app --template-name v1 --version-label v1 --environment-name v1clone --option-settings file://options.txt

# The above option setting defines the IAM instance profile. You can specify the ARN or the profile name.
# Determine if the new environment is Green and Ready.
aws elasticbeanstalk describe-environments --environment-names my-env

# If the new environment does not come up Green and Ready, you should decide if you want to retry the operation or leave the environment in its current state for investigation. Make sure to terminate the environment after you are finished, and clean up any unused resources.
