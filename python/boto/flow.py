import boto3
import re
import socket

session = boto3.Session(profile_name='famc-legacy')
client = session.client('logs', region_name='us-east-1')

response = client.describe_log_groups()

all_logs = {}
for log in response.get('logGroups'):
    log_group_name = log.get('logGroupName')
    if 'cfg' and 'vpc' in log_group_name:
        flowlog_list = []
        all_streams = []
        stream_batch = client.describe_log_streams(logGroupName=log_group_name)
        all_streams += stream_batch['logStreams']
        while 'nextToken' in stream_batch:
            stream_batch = client.describe_log_streams(
                logGroupName=log_group_name, nextToken=stream_batch['nextToken'])
            all_streams += stream_batch['logStreams']
        for row in all_streams:
            flowlog_list.append(row.get('logStreamName'))
        all_logs.update({log_group_name: flowlog_list})

# all interfaces attached to an EC2
all_server_interfaces = {}
interfacedict = {}
server_list = session.resource('ec2', region_name='us-east-1')
for server in server_list.instances.all():
    tags = server.tags
    if tags is not None:
        for tag in tags:
            if tag.get('Key') == 'Name':
                hostname = tag.get('Value')
                interfacelist = []
                for interface in server.network_interfaces:
                    interfacelist.append(interface.id)
        interfacedict.update({hostname: interfacelist})

all_my_logs_to_parse = {}
amazon = []
for server_name in interfacedict.keys():
    file1 = open(server_name + '.txt', 'w')
    file2 = open(server_name + '_full.txt', 'w')
    interface = interfacedict.get(server_name)
    if len(interface) > 0:
        for inter in interface:
            inter = inter + '-all'
            key_list = list(all_logs.keys())
            for vpc in key_list:
                if inter in all_logs.get(vpc):
                    response = client.get_log_events(
                        logGroupName=vpc, logStreamName=inter)
                    ip = []
                    port = []
                    srcip_port = []
                    for i in response.get('events'):
                        entry = i.get('message')
                        if len(entry.split()) == 14:
                            ver, acct, interface, srcaddr, dstaddr, srcport, dstport, protocol, numpackets, numbytes, starttime, endtime, action, logstatus = entry.split()
                            val = srcaddr + ':' + srcport

                            try:
                                srcaddr_dns = socket.gethostbyaddr(srcaddr)
                                if srcaddr_dns not in amazon:
                                    amazon.append(srcaddr_dns)
                            except BaseException:
                                srcaddr_dns = '-'

                            try:
                                dstaddr_dns = socket.gethostbyaddr(dstaddr)
                                if dstaddr_dns not in amazon:
                                    amazon.append(dstaddr_dns)
                            except BaseException:
                                dstaddr_dns = '-'

                            if val not in srcip_port:
                                srcip_port.append(val)

                            file2.write(
                                ver +
                                ';' +
                                acct +
                                ';' +
                                interface +
                                ';' +
                                srcaddr_dns +
                                ';' +
                                srcaddr +
                                ';' +
                                ';' +
                                dstaddr_dns +
                                ';' +
                                dstaddr +
                                ';' +
                                srcport +
                                ';' +
                                dstport +
                                ';' +
                                protocol +
                                ';' +
                                numpackets +
                                ';' +
                                numbytes +
                                ';' +
                                starttime +
                                ';' +
                                endtime +
                                ';' +
                                action +
                                '\n')
                    for i in srcip_port:
                        ip, port = i.split(':')
                        try:
                            dns = socket.gethostbyaddr(ip)
                        except BaseException:
                            dns = '-'
                        if len(port) < 5 and '-' not in port:
                            file1.write(f"{server_name};{dns}:{ip};{port}\n")
    file1.close()
    file2.close()
