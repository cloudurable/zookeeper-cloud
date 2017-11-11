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
# Remove slf4j log4j jar files - can't remove all the way ZooKeeper depends on log4j
find opt/zookeeper/lib/ -name "*log4j*" | grep slf4j | xargs rm




# Copy the bin files for zookeeper
cp zookeeper-src/bin/*.sh opt/zookeeper/bin

# Create the zookeeper config file
tee opt/zookeeper/conf/zoo.cfg << END

dataDir=opt/zookeeper/data/snapshots
dataLogDir=opt/zookeeper/data/transactions
clientPort=2181
initLimit=5
syncLimit=2
autopurge.purgeInterval=12
autopurge.snapRetainCount=5
tickTime=5000
maxClientCnxns=0
#clientPortAddress=
cnxTimeout=20000
minSessionTimeout=24000
maxSessionTimeout=60000
standaloneEnabled=true

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

set CFG_FILE="\$ZOOCFGDIR/\$ZOOCFG"
sed  -i  's/opt\/zookeeper/\/opt\/zookeeper/g' \$CFG_FILE
sed  -i  "s/clientPort=2181/clientPort=\$ZOO_CLIENT_PORT/g" \$CFG_FILE
sed  -i  "s/initLimit=5/initLimit=\$ZOO_INIT_LIMIT/g" \$CFG_FILE
sed  -i  "s/syncLimit=2/syncLimit=\$ZOO_SYNC_LIMIT/g" \$CFG_FILE
sed  -i  "s/tickTime=5000/tickTime=\$ZOO_TICK_TIME/g" \$CFG_FILE
sed  -i  "s/cnxTimeout=2000/cnxTimeout=\$ZOO_MAX_CLIENT_CNXNS/g" \$CFG_FILE
sed  -i  "s/standaloneEnabled=true/standaloneEnabled=\$ZOO_STANDALONE_ENABLED/g" \$CFG_FILE
sed  -i  "s/minSessionTimeout=24000/minSessionTimeout=\$ZOO_MIN_SESSION_TIMEOUT/g" \$CFG_FILE
sed  -i  "s/maxSessionTimeout=60000/maxSessionTimeout=\$ZOO_MAX_SESSION_TIMEOUT/g" \$CFG_FILE
sed  -i  "s/autopurge.purgeInterval=12/autopurge.purgeInterval=\$ZOO_AUTO_PURGE_INTERVAL/g" \$CFG_FILE
sed  -i  "s/autopurge.snapRetainCount=5/autopurge.snapRetainCount=\$ZOO_AUTO_PURGE_SNAP_RETAIN_COUNT/g" \$CFG_FILE
DATA_DIR=\$(echo $ZOO_DATA_DIR | sed 's/\//\\\//g')
sed  -i  "s/dataDir=\/opt\/zookeeper\/data\/snapshots/dataDir=\$DATA_DIR/g" \$CFG_FILE
DATA_LOG_DIR=\$(echo $ZOO_DATA_LOG_DIR | sed 's/\//\\\//g')
sed  -i  "s/dataLogDir=\/opt\/zookeeper\/data\/transactions/dataLogDir=\$DATA_LOG_DIR/g" \$CFG_FILE




if [ "x$ZOO_CLIENT_PORT_ADDRESS" != "x" ]
then
  sed  -i  "s/#clientPortAddress=/clientPortAddress=\$ZOO_CLIENT_PORT_ADDRESS/g" \$CFG_FILE
fi



idx=1
if env | grep -q ^ENSEMBLE=
then
  echo "ENSEMBLE SET \$ENSEMBLE"
  for server in \${ENSEMBLE//,/ }
  do
    echo "#ENSEMBLE\${idx} changed to \${server}:\${ZOO_PEER_PORT}:\${ZOO_LEADER_PORT}"
    sed -i "s/#ENSEMBLE\${idx}/server.\${idx}=\${server}:\${ZOO_PEER_PORT}:\${ZOO_LEADER_PORT}/" \$CFG_FILE
   let "idx=idx+1"
  done
else
  echo "ENSEMBLE NOT SET"
fi

tee /opt/zookeeper/data/snapshots/myid << EOF
\$ZOO_MY_ID
#myid file

EOF

cat \$CFG_FILE

\$ZOOBINDIR/zkServer.sh start-foreground


END

chmod +x opt/zookeeper/bin/run.sh
