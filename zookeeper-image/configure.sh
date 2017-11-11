#!/usr/bin/env bash

rm -rf opt
mkdir -p opt/zookeeper
mkdir -p opt/zookeeper/bin
mkdir -p opt/zookeeper/lib
mkdir -p opt/zookeeper/conf
mkdir -p opt/zookeeper/data
mkdir -p opt/zookeeper/data/transactions
mkdir -p opt/zookeeper/data/snapshots

# Copy main zookeeper jar
cp zookeeper-src/dist-maven/zookeeper-3.4.11.jar opt/zookeeper/lib
# Copy dependencies for zookeeper
cp zookeeper-src/lib/*.jar opt/zookeeper/lib
# Remove slf4j log4j jar files - can't they have a dependency
find opt/zookeeper/lib/ -name "*log4j*" | grep slf4j | xargs rm




# Copy the bin files for zookeeper
cp zookeeper-src/bin/*.sh opt/zookeeper/bin

# Create the zookeeper config file - TODO improve this
tee opt/zookeeper/conf/zoo.cfg << END

dataDir=opt/zookeeper/data/snapshots
dataLogDir=opt/zookeeper/data/transactions
clientPort=2181

#ENSEMBLE0
#ENSEMBLE1
#ENSEMBLE2
#ENSEMBLE3
#ENSEMBLE4
#ENSEMBLE5

END



tee opt/zookeeper/bin/run.sh << END
#!/usr/bin/env bash
set -e

if [ -z "\$CLIENT_PORT" ]; then
    export CLIENT_PORT=2181
fi

if [ -z "\$PEER_PORT" ]; then
    export PEER_PORT=2888
fi

if [ -z "\$LEADER_PORT" ]; then
    export LEADER_PORT=3888
fi

sed  -i  's/opt\/zookeeper/\/opt\/zookeeper/g' /opt/zookeeper/conf/zoo.cfg
sed  -i  "s/clientPort=2181/clientPort=\$CLIENT_PORT/g" /opt/zookeeper/conf/zoo.cfg

idx=0
if env | grep -q ^ENSEMBLE=
then
  echo "ENSEMBLE SET \$ENSEMBLE"
  for server in \${ENSEMBLE//,/ }
  do
    echo "#ENSEMBLE\${idx} changed to \${server}:\${PEER_PORT}:\${LEADER_PORT}"
    sed -i "s/#ENSEMBLE\${idx}/\${server}:\${PEER_PORT}:\${LEADER_PORT}/" /opt/zookeeper/conf/zoo.cfg
   let "idx=idx+1"
  done
else
  echo "ENSEMBLE NOT SET"
fi

/opt/zookeeper/bin/zkServer.sh start-foreground

END

chmod +x opt/zookeeper/bin/run.sh
