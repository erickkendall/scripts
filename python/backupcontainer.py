import re
import docker
from datetime import datetime
from datetime import timedelta
from datetime import date

#
# Read docker-compose.yml for containers that should be running.
# We don't look at running containers because a container could
# be down and we'd miss backing it up. 
#
def read_docker_compose():
  container_list=[]
  dockercompose = open("/home/darvis/zanbeel/docker-compose.yml", "r") 
  for line in dockercompose.readlines():
      if re.findall("container_name", line) and not re.findall("#", line):
          container = re.sub('\n', '', line ).split(":")[1].replace(" ", "")
          container_list.append(container)
  dockercompose.close()
  return container_list

#
# Commit running containers. 
#
def commit_running_container(container):

  # 2022-07-11
  image_list = []
  currentDay = str(datetime.now().day).zfill(2)
  currentMonth = str(datetime.now().month).zfill(2)
  currentYear = str(datetime.now().year)


  image_name = container + '_' + currentYear + '-' + currentMonth + '-' + currentDay
  client = docker.from_env()
  try:
    client.images.get(image_name)
    print("Current image for " + container + " exists!")
  except:
    image=client.containers.get(container).commit(image_name)
    image_list.append(image)

#
# remove old images
#
def delete_old_images(numdays,images):
  today = datetime.now()
  client = docker.from_env()
  for index in range(1,numdays): # skip removing image from today
    n_days_ago = str(today - timedelta(days=index)).split(' ')[0]
    print(n_days_ago)
    for image in images:
        image_name=image + '_' + n_days_ago
        try:
          client.images.remove(image_name)
        except:
          print("Image not found: " + image_name)


def backup_volumes():

  currentDay = str(datetime.now().day).zfill(2)
  currentMonth = str(datetime.now().month).zfill(2)
  currentYear = str(datetime.now().year)

  volumes=['mongo_data','es_data','graylog_journal','prometheus_data','grafana_data','license','tsdb_data']
  client = docker.from_env()
  for vol in volumes:
    mount=vol+':/volume'
    tar="tar -cjf /backup/" + vol + ".tar_" +  currentYear + '-' + currentMonth + '-' + currentDay + ".bz2 -C /volume ./"
    container = client.containers.run("alpine", tar, volumes=[mount, '/home/darvis/backup:/backup'], detach=True, remove=True)

def restore_docker_compose():
  container_list=[]
  dockercompose = open("/home/darvis/zanbeel/docker-compose.yml", "r") 
  for line in dockercompose.readlines():
      if re.findall("image:", line) and not re.findall("#", line):
          print(line)

#
# Commit running containers. 
#
def commit_running_container(container):

  # 2022-07-11
  image_list = []
  currentDay = str(datetime.now().day).zfill(2)
  currentMonth = str(datetime.now().month).zfill(2)
  currentYear = str(datetime.now().year)

container_list = read_docker_compose()
for container in container_list:
    commit_running_container(container)

backup_volumes()

# delete_old_images(3,container_list)

# restore_docker_compose()
