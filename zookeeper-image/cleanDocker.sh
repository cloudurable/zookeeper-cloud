docker ps -a | grep cloudurable/zookeeper-image | awk '{ print $1}' \
  | xargs docker stop

docker ps -a | grep cloudurable/zookeeper-image | awk '{ print $1}' \
  | xargs docker rm

docker images | grep cloudurable/zookeeper-image | awk '{ print $3}' \
    | xargs docker rmi -f
