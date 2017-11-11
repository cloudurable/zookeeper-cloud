
# Use
## Run
```sh
docker run --name zookeeper \
  -p 2181:2181 \
  -e ENSEMBLE=foo,bar,baz \
  cloudurable/zookeeper-image:latest \
  /opt/zookeeper/bin/run.sh
```


# Dev


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
