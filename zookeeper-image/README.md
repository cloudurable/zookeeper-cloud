
# What is Apache Zookeeper?

Apache ZooKeeper provides leadership election, consensus, distributed configuration service, synchronization service, and naming registry for large distributed systems.



# How to use this image

## Run
```sh
docker run --name zookeeper \
  -p 2181:2181 \
  --restart always \
  -e ENSEMBLE=zoo1,hostzoo2,zookeeper3 \
  cloudurable/zookeeper-image:0.2 \
  /opt/zookeeper/bin/run.sh
```


## Environment Variables

* ENSEMBLE - holds comma delimited list of servers
* ZOO_CLIENT_PORT - client port
* ZOO_LEADER_PORT - leader port
* ZOO_PEER_PORT - peer port
* MY_ID - id of ZooKeeper server (1 - 255)

```sh
"changes": [
    "ENV ZOO_CLIENT_PORT 2181",
    "ENV ZOO_PEER_PORT 2888",
    "ENV ZOO_LEADER_PORT 3888",
    "ENV ZOO_MY_ID 1",
    "ENV ZOO_TICK_TIME 5000",
    "ENV ZOO_INIT_LIMIT 5",
    "ENV ZOO_SYNC_LIMIT 2",
    "ENV ZOO_MAX_CLIENT_CNXNS 60",
    "ENV ZOO_MIN_SESSION_TIMEOUT 24000",
    "ENV ZOO_MAX_SESSION_TIMEOUT 60000",
    "ENV ZOO_STANDALONE_ENABLED true",
    "ENV ZOO_CLIENT_PORT_ADDRESS ''",
    "ENV ZOO_AUTO_PURGE_SNAP_RETAIN_COUNT=5",
    "ENV ZOO_AUTO_PURGE_INTERVAL=12",
    "ENV ZOO_DATA_DIR /opt/zookeeper/data/snapshots",
    "ENV ZOO_DATA_LOG_DIR /opt/zookeeper/data/transactions",
    "ENV ENSEMBLE ''",
    "ENV JMXLOCALONLY true",
    "ENV JMXDISABLE true",
    "ENV JMXPORT ''",
    "ENV JMXAUTH false",
    "ENV JMXSSL false",
    "ENV JMXLOG4J false",
    "ENV SERVER_JVMFLAGS ''",
    "ENV JVMFLAGS ''",
    "ENV ZOOCFGDIR /opt/zookeeper/conf",
    "ENV ZOOBINDIR /opt/zookeeper/bin",
    "ENV ZOOCFG zoo.cfg",
    "ENV EXPOSE 2181 2888 3888",
    "ENTRYPOINT /opt/zookeeper/bin/run.sh"
  ]
```


## Example Docker Compose file to run an Ensemble of ZooKeeper servers (cluster)

```yaml
version: '3'
services:
  zookeeper0:
    image: "cloudurable/zookeeper-image:0.2"
    restart: always
    ports:
     - "2181:2181"
    environment:
     - ENSEMBLE=zookeeper0,zookeeper1,zookeeper2
     - MY_ID=1
  zookeeper1:
    image: "cloudurable/zookeeper-image:0.2"
    restart: always
    environment:
     - ENSEMBLE=zookeeper0,zookeeper1,zookeeper2
     - MY_ID=2
  zookeeper2:
    image: "cloudurable/zookeeper-image:0.2"
    restart: always
    environment:
     - ENSEMBLE=zookeeper0,zookeeper1,zookeeper2
     - MY_ID=3
```


This above starts Zookeeper in [replicated mode](http://zookeeper.apache.org/doc/current/zookeeperStarted.html#sc_RunningReplicatedZooKeeper). Run `docker-compose up`\ and wait for it to initialize completely. Ports `2181, 2888 and 3888` will be exposed.


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
`/opt/zookeeper/bin/run.sh` using sed to edit the ZooKeeper config file.


## Configuration

Zookeeper configuration is located in `/opt/zookeeper/conf`.

To change the config, mount a new config file as a volume:

```
	$ docker run --name node0-zookeeper --restart always \
      -d -v $(pwd)/zoo.cfg:/opt/zookeeper/conf/zoo.cfg \
      cloudurable/zookeeper-image
```

## Environment variables

ZooKeeper defaults described above are used. They can be overridden using the following environment variables.

    $ docker run -e "ZOO_INIT_LIMIT=10" --name node0-zookeeper --restart always -d cloudurable/zookeeper-image

### `ZOO_TICK_TIME`

Defaults to `2000`. ZooKeeper's `tickTime`

> The length of a single tick, which is the basic time unit used by ZooKeeper, as measured in milliseconds. It is used to regulate heartbeats, and timeouts. For example, the minimum session timeout will be two ticks

### `ZOO_INIT_LIMIT`

Defaults to `5`. ZooKeeper's `initLimit`

> Amount of time, in ticks (see tickTime), to allow followers to connect and sync to a leader. Increased this value as needed, if the amount of data managed by ZooKeeper is large.

### `ZOO_SYNC_LIMIT`

Defaults to `2`. ZooKeeper's `syncLimit`

> Amount of time, in ticks (see tickTime), to allow followers to sync with ZooKeeper. If followers fall too far behind a leader, they will be dropped.

### `ZOO_MAX_CLIENT_CNXNS`

Defaults to `60`. ZooKeeper's `maxClientCnxns`

> Limits the number of concurrent connections (at the socket level) that a single client, identified by IP address, may make to a single member of the ZooKeeper ensemble.

### `ZOO_STANDALONE_ENABLED`

Defaults to `false`. Zookeeper's [`standaloneEnabled`](http://zookeeper.apache.org/doc/trunk/zookeeperReconfig.html#sc_reconfig_standaloneEnabled)

> Prior to 3.5.0, one could run ZooKeeper in Standalone mode or in a Distributed mode. These are separate implementation stacks, and switching between them during run time is not possible. By default (for backward compatibility) standaloneEnabled is set to true. The consequence of using this default is that if started with a single server the ensemble will not be allowed to grow, and if started with more than one server it will not be allowed to shrink to contain fewer than two participants.

## Replicated mode

Environment variables below are mandatory if you want to run Zookeeper in replicated mode.

### `ZOO_MY_ID`

The id must be unique within the ensemble and should have a value between 1 and 255. Do note that this variable will not have any effect if you start the container with a `/data` directory that already contains the `myid` file.

### `ENSEMBLE`

This variable allows you to specify a comma delimited list of host names of the Zookeeper ensemble.


## Where to store data

This image is configured with volumes at  `/opt/zookeeper/data/snapshots` and
`/opt/zookeeper/data/transactions` to hold snapshots of the Zookeeper in-memory database
 and the transaction log of updates to the database, respectively.

> Be careful where you put the transaction log. A dedicated transaction log device is key to consistent good performance. Putting the log on a busy device will adversely affect performance.


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
## We added an entrypoint so now you have to do this
docker run -it --entrypoint "/bin/bash"  cloudurable/zookeeper-image

```

## Clean docker

```sh
docker ps -a | grep cloudurable/zookeeper-image | awk '{ print $1}' \
  | xargs docker rm

docker images | grep cloudurable/zookeeper-image | awk '{ print $3}' \
    | xargs docker rmi -f
```
