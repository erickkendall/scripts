import re
import docker
import argparse
import shutil
from datetime import datetime
from datetime import timedelta
from datetime import date

parser = argparse.ArgumentParser(description="Backup Zanbeel.")
group = parser.add_mutually_exclusive_group()
parser = argparse.ArgumentParser()
parser.add_argument("-s", "--source", help="Zanbeel home directory.")
parser.add_argument("-d", "--destination", help="Backup directory to copy files to.")

args = parser.parse_args()

def backup_volumes():

  volumes=['mongo_data','es_data','graylog_journal','prometheus_data','grafana_data','license','tsdb_data']
  client = docker.from_env()
  for vol in volumes:
    mount=vol+':/volume'
    tarparam="tar -cjf /backup/" + vol + ".tar_" + ".bz2 -C /volume ./"

    container = client.containers.run("alpine", tarparam, volumes=[mount, '/home/darvis/backups:/backup'], detach=True, remove=True)

def copy_files(source,destination):

  docker_files=[ "docker-compose.yml",".env"]

  for backup_file in docker_files:
    src_file=source+'/'+backup_file
    dest_file=destination+'/'+backup_file
    try:
      shutil.copy2(src_file, dest_file)
    except:
        print("File not found. Please, check that the directory or file exists.")
        break


copy_files(args.source,args.destination)

backup_volumes()
