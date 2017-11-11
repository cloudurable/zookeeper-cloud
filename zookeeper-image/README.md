
# Use
## Run
```sh
docker run --name zookeeper \
  -p 2181:2181 \
  -e ENSEMBLE=zoo1,hostzoo2,zookeeper3 \
  cloudurable/zookeeper-image:latest \
  /opt/zookeeper/bin/run.sh
```


## Environment Variables

* ENSEMBLE - holds comma delimited list of servers
* CLIENT_PORT - client port
* LEADER_PORT - leader port
* PEER_PORT - peer port
* MY_ID - id of ZooKeeper server (1 - 255)


## Example Docker Compose file to run an Ensemble of ZooKeeper servers (cluster)

```yaml
version: '3'
services:
  zookeeper0:
    image: "cloudurable/zookeeper-image:latest"
    ports:
     - "2181:2181"
    environment:
     - ENSEMBLE=zookeeper0,zookeeper1,zookeeper2
     - MY_ID=1
    entrypoint: /opt/zookeeper/bin/run.sh
  zookeeper1:
    image: "cloudurable/zookeeper-image:latest"
    environment:
     - ENSEMBLE=zookeeper0,zookeeper1,zookeeper2
     - MY_ID=2
    entrypoint: /opt/zookeeper/bin/run.sh
  zookeeper2:
    image: "cloudurable/zookeeper-image:latest"
    environment:
     - ENSEMBLE=zookeeper0,zookeeper1,zookeeper2
     - MY_ID=3
    entrypoint: /opt/zookeeper/bin/run.sh


```

## Testing cluster
```sh
echo stat | nc localhost 2181
Zookeeper version: 3.4.11-37e277162d567b55a07d1755f0b31c32e93c01a0, built on 11/01/2017 18:06 GMT
Clients:
 /172.18.0.1:32952[0](queued=0,recved=1,sent=0)

Latency min/avg/max: 0/0/0
Received: 7
Sent: 6
Connections: 1
Outstanding: 0
Zxid: 0x0
Mode: follower
Node count: 4
```

The ZooKeeper config gets generated based on the environment variables that you specify by
`/opt/zookeeper/bin/run.sh`.



# Dev Notes




## Build base image
```sh
packer build base-java-packer.json
```

We build a base image which installs Java, updates the OS, etc.
This is time consuming. We try to do it once.

## Run packer
```sh
packer build packer.json
```

## Snoop around
```sh
docker run -it cloudurable/zookeeper-image:latest

```

## Clean docker

```sh
docker ps -a | grep cloudurable/zookeeper-image | awk '{ print $1}' \
  | xargs docker rm

docker images | grep cloudurable/zookeeper-image | awk '{ print $3}' \
    | xargs docker rmi -f
```
