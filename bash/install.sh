#!/bin/bash

# location of tar files to be loaded
dir=$1

# Docker images built by Darvis
darvis_services=("ai_core" "auth" "cleaner" "config" "dashboard" "enricher" "historian" "ocr" "persistence" "supplier" "transmitter")

# Publicly available Docker images
public_services=("elasticsearch" "graylog" "mongo3" "mongo423" "redis" "timescaledb")

# Required Docker volumes
volumes=("mongo_data" "es_data" "graylog_journal" "config_data" "prometheus_data" "grafana_data" "license" "tsdb_data")

remove_all() {

  # stop all Docker containers
  docker stop `docker ps | awk '{ print $1 }'`

  # remove all Docker containers
  docker rm `docker ps | awk '{ print $1 }'`
  
  # remove all images
  docker rmi --force `docker image ls | awk '{ print $3 }'`

}

verify_zanbeel() {
  listofservices="$@"
  result=0
  # Ensure docker-compose.yml file, .env file in the zanbeel directory and images are installed
  if [[ `ls ~/zanbeel/docker-compose.yml > /dev/null 2>&1; echo $?` == "0" ]] && \
	  [[ `ls ~/zanbeel/.env > /dev/null 2>&1; echo $?` == "0" ]]; then
    # Check that image need for service is installed
    for service in ${listofservices}; do
      image_count=`docker image ls | grep $service | wc -l`
      if [ "$service" == "mongo" ] && [ "$image_count"-eq 2 ]; then
        echo "Both mongo images are installed."
      elif [ "$image_count" -eq 1 ]; then
        echo "$service image is installed" 
      else
        echo "$service image is missing."
        result=1
      fi
    done
  else
    echo "Missing docker-compose and/or .env file in zanbeel directory!"
    result=1
  fi
  return $result
}

# Check for required volumes
check_volumes() {
  listofvolumes="$@"
  for docker_volume in ${listofvolumes}; do
    check_volume=`docker volume ls | grep "$docker_volume" > /dev/null 2>&1 ; echo $?`
    if [ "${check_volume}" == "0" ]; then
      echo "Docker volume $docker_volume exists."
    else
      echo "Docker volume $docker_volume does not exist. Creating $volume"
      docker volume create --name=$docker_volume
    fi
  done
}

# Check if containers are running
docker_running() {
  compose_runing=`docker-compose ps | tail \-1 | grep "^-"`
  
  if [ -z "$compose_running" ]; then
    echo "Docker containers are still running."
    return 0
  else
    echo "Docker containers are not running."
    return 1
  fi
}

function load_images() {
  listofservices="$@"
  for service in ${listofservices}; do
    tarfilename=`ls $dir | grep $service`
    if [ -z "$tarfilename" ]; then
      echo "no tar file found $service"
    else
      tarfile="$dir/$tarfilename"
      echo "Processing $tarfile..."
      is_darvis=`echo $tarfilename | grep "\-"`
      if [ -z "$is_darvis" ]; then
	# load public Docker images
        if [ "$service" == "timescaledb" ]; then
          sha=`docker load -i $tarfile | grep "sha"  | cut -d":" -f3`; docker tag $sha $service
        else
          docker load -i $tarfile
        fi
      else
        if [ "${service:0:2}" == "ai" ]; then
          ai_core_sha=`docker load -i $tarfile | grep "sha"  | cut -d":" -f3`
        elif [ "${service:0:3}" == "ocr" ]; then
          sha=`docker load -i $tarfile | grep "sha"  | cut -d":" -f3`;  docker tag $sha ocr_warehouse
        else
          sha=`docker load -i $tarfile | grep "sha"  | cut -d":" -f3`; docker tag $sha $service
        fi
      fi
    fi
  done
}
# Ensure require Docker volumes have been created
check_volumes "${volumes[@]}"

# Check if containers are running
if [ docker_running ]; then
  docker-compose down
fi

# remove existing Docker container images and contianers
read -p "Do you wish to remove ALL existing images? (yes/no) " yn
if [ "$yn" == "yes" ]; then
  echo "Removing existing images."
  remove_all
fi

load_images "${darvis_services[@]}"
load_images "${public_services[@]}"

docker_compose=`ls $dir/docker-compose.yml`
if [ -n "$docker_compose" ]; then
  echo "Updating docker-compose.yml file."
  cp $dir/docker-compose.yml ~/zanbeel
fi

env=`ls $dir/env ; echo $?`
if [ -n "env" ]; then
  echo "Updating .env. file"
  cp $dir/env ~/zanbeel/.env
fi

verify_darvis=`verify_zanbeel "${darvis_services[@]}"; echo $?`
verify_public=`verify_zanbeel "${public_services[@]}"; echo $?`

echo "$verify_darvis $verify_public"
