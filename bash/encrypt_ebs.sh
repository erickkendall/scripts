#!/bin/bash -x

function is_complete() {

complete=1
resource=$1

OPTION="${resource/-[0-9|a-z|A-Z]*/}"
  case $OPTION in
  i)
  result=`aws ec2 describe-instances --profile darvis --region us-east-1 --filters "Name=instance-id,Values=$resource"  --query "Reservations[].Instances[].State.Name" --output text`
  if [ "$result" == "stopped" ]
  then
    complete=0
  fi
  ;;
  snap)
  result=`aws ec2 describe-snapshots --snapshot-ids $resource --query 'Snapshots[].State' --output text`
  if [ "$result" == "completed" ]
  then
    complete=0
  fi
  ;;

  vol)
  result=`aws ec2 describe-volumes --volume-ids $resource  --query 'Volumes[].State' --output text`
  if [ "$result" == "available" ]
  then
    complete=0
  fi
  ;;

  *)
  echo “User Selected Choice not present”
  esac

echo $complete
}

#
# Enter an instance ID 
#
read -p "Enter instance ID: " instance_id

if [ -n "$instance_id" ]
then
  #
  # Step One - Ensure instance exist
  #  
  echo "Verify instance $instance_id exists."
  instance_exists=`aws ec2 describe-instances --profile darvis  --region us-east-1  --filters "Name=instance-id,Values=$instance_id"   --query 'Reservations[].Instances[].InstanceId' --output text`

  if [ -n "$instance_exists" ]
  then
    #
    # Step Two - Determine availability zone (AZ) of instance because encrypted volume needs to be in same AZ
    #
    avail_zone=`aws ec2 describe-instances --profile darvis  --region us-east-1 --filters "Name=instance-id,Values=$instance_id"  --query 'Reservations[].Instances[].Placement.AvailabilityZone' --output text`
    echo "Instance is running in $avail_zone."
    
    #
    # Step Three - Determine root device name which the encrypted volume will be mapped to in step 
    #
    # aws ec2 describe-instances --profile darvis  --region us-east-1 --filters 'Name=instance-id, Values=$instance_id'  --query 'Reservations[].Instances[].RootDeviceName' --output text
    device=`aws ec2 describe-instances --profile darvis  --region us-east-1 --filters "Name=instance-id, Values=$instance_id"  --query "Reservations[].Instances[].BlockDeviceMappings[].DeviceName"  --output text`
    echo "Root device of $instance_id is $device."
    
    # Step Four - Determine the volume ID 
    volume=`aws ec2 describe-instances --profile darvis  --region us-east-1 --filters "Name=instance-id,Values=$instance_id"  --query "Reservations[].Instances[].BlockDeviceMappings[].Ebs.VolumeId"  --output text`
    echo "Volume ID of $instance_id is $volume."

    # Step Five - Create snapshot of root volume
    snapshot=`aws ec2 create-snapshot --volume-id $volume --description "This is my root volume snapshot" --query 'SnapshotId' --output text`
    echo "Creating snapshot of $volume..."
    
    # Step Six - Wait for snapshot to complete
    var=`is_complete $snapshot`
    while [ $var != 0 ]
    do
      sleep 10
      var=`is_complete $snapshot`
    done
    
    # Step Seven - Create encrypted volume from snapshot
    encrypted_vol=`aws ec2 create-volume --volume-type gp3 --snapshot-id $snapshot --availability-zone $avail_zone --encrypted  --query 'VolumeId' --output text`
    echo "Creating encrypted volme $encrypted_vol for $instance_id..."

    var=`is_complete $encrypted_vol`
    while [ $var != 0 ]
    do
      sleep 10
      var=`is_complete $encrypted_vol`
    done

    # Step Eight - Wait for snapshot to complete
    sleep 60
    echo "Created encrypted volme $encrypted_vol."
   
    # Step Nine - Stop the instance in order to detach the existing root volume
    aws ec2 stop-instances --instance-ids $instance_id
    echo "Stopping instance $instance_id."
    
    # Step Ten - Wait for shutdown of instance to complete
    var=`is_complete $instance_id`
    while [ $var != 0 ]
    do
      sleep 10
      var=`is_complete $instance_id`
    done
    
    # Step Eleven - Detach the existing root volume
    aws ec2 detach-volume --volume-id $volume
    echo "Detach existing volume $volume from $instance_id."
    var=`is_complete $volume`
    while [ $var != 0 ]
    do
      sleep 10
      var=`is_complete $volume`
    done
    
    # Step Twelve - Attach the encypted volume created in step six to device found in step two
    aws ec2 attach-volume --volume-id $encrypted_vol --instance-id $instance_id --device $device
    echo "Attach newly created encrypted volume $encrypted_vol from $instance_id."
    sleep 60
    
    # Final Step - Start EC2 instance
    aws ec2 start-instances --instance-ids $instance_id
    echo "Starting instance $instance_id."
  else
    echo "ERROR: Instance $instance_id not found."
  fi
else
  echo "Please enter a valid instance ID."
fi
