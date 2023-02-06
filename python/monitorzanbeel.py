import argparse
import docker
import requests
from requests.structures import CaseInsensitiveDict

parser = argparse.ArgumentParser(description="Verify application is running")
group = parser.add_mutually_exclusive_group()
parser = argparse.ArgumentParser()
parser.add_argument("base_url", help="URL to the Docker server.")
parser.add_argument("docker_compose", help="Location of docker-compose.yml file.")
parser.add_argument("username", help="User name.")
parser.add_argument("password", help="Login password")

args = parser.parse_args()

# Docker base URL
url = 'unix:/' + args.base_url


def check_containers(container_list):

    client = docker.DockerClient(base_url=url)

    containers = client.containers.list('all')

    #
    # check whehter list of Docker containers are running
    #
    for y in range(len(containers)):
        if containers[y].status != 'running' and containers[y].name in container_list:
            print(containers[y].name + " is not running!")
            return False
    return True


def check_urls():

    #
    # list of URL(s) to check
    #
    url = {"login": "https://127.0.0.1:8090/token",
           "floor_state": "https://127.0.0.1:8060/apis/floor_state"}

    #
    # headers needed for POST
    #
    headers = CaseInsensitiveDict()
    headers["Content-Type"] = "application/x-www-form-urlencoded"
    headers["Accept"] = "application/json"

    data = {"username": args.username, "password": args.password, }

    resp = requests.post(url['login'], headers=headers, data=data, verify=False)

    if resp.status_code == 200:

        token = resp.json().get('data').get('access_token')

        #
        # headers needed for GET
        #
        headers = CaseInsensitiveDict()
        headers["Authorization"] = "Bearer " + token

        resp = requests.get(url['floor_state'], headers=headers, verify=False)
        if resp.status_code == 200:
            return True
        else:
            return False

    #
    # token not found
    #
    else:
        return False

mycontainerlist = []
with open(args.docker_compose) as f:
    contents = f.readlines()

#
# find Docker containers in docker-compose.yml
#
for line in contents:
    if "container_name:" in line and "#" not in line:
        mycontainerlist.append(line.split(':')[1].strip('\ ').strip('\n'))

if check_containers(mycontainerlist):
    if check_urls():
        print("Docker containers are running and connectvity test to application are working.")
