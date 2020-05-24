#!/bin/sh

echo "Executing $0"

# Below only is needed for this docker test. During build , the server name is set to host.docker.internal which needes to be corrected.
sed -i "s/serverHost: host.docker.internal/serverHost: appd-ec/" /home/appdynamics/platform/platform-admin/conf/PlatformAdminApplication.yml

cd /home/appdynamics/platform/platform-admin/bin

CONT_GROOFY=/home/appdynamics/platform/platform-admin/archives/controller/*/playbooks/controller-demo.groovy
sed -i "s/controller_min_ram_in_mb = .*/controller_min_ram_in_mb = 1 * 1024/" $CONT_GROOFY 
sed -i "s/controller_min_cpus = .*/controller_min_cpus = 2/" $CONT_GROOFY
sed -i "s/controller_data_min_disk_space_in_mb = .*/controller_data_min_disk_space_in_mb = 20 * 1024/" $CONT_GROOFY

./platform-admin.sh start-platform-admin
echo "#########################"
#sleep 5

./platform-admin.sh login --user-name admin --password admin
./platform-admin.sh create-platform --name DEV --installation-dir /home/appdynamics/platform/product
./platform-admin.sh add-credential --credential-name cred1 --type ssh --user-name appdynamics --ssh-key-file ~/.ssh/id_rsa
./platform-admin.sh add-hosts --hosts localhost
./platform-admin.sh submit-job --service controller --job install --args controllerPrimaryHost=localhost controllerAdminUsername=admin controllerAdminPassword=admin controllerRootUserPassword=root newDatabaseRootPassword=root newDatabaseUserPassword=admin controllerProfile=Demo
./platform-admin.sh start-controller-appserver

./platform-admin.sh add-hosts --hosts appd-event-01 --credential cred1
./platform-admin.sh install-events-service  --profile dev --hosts appd-event-01 --data-dir /home/appdynamics/platform/data --platform-name DEV
ssh appd-event-01 sh /home/appdynamics/platform/product/events-service/processor/bin/tool/tune-system.sh

# For second time startup, delete last started process id files if exist
ssh appd-event-01 rm -f /home/appdynamics/platform/product/events-service/processor/*.id

./platform-admin.sh submit-job --platform-name DEV --service events-service --job start
./platform-admin.sh show-events-service-health

cp /home/appdynamics/license.lic /home/appdynamics/platform/product/controller/license.lic

curl --user root@system:root -X POST http://localhost:8090/controller/rest/configuration?name=eum.cloud.host\&value=http://appd-eum:7001
curl --user root@system:root -X POST http://localhost:8090/controller/rest/configuration?name=eum.beacon.host\&value=http://localhost:7001
curl --user root@system:root -X POST http://localhost:8090/controller/rest/configuration?name=eum.beacon.https.host\&value=https://localhost:7002
curl --user root@system:root -X POST http://localhost:8090/controller/rest/configuration?name=eum.mobile.screenshot.host\&value=http://localhost:7001
curl --user root@system:root -X POST http://localhost:8090/controller/rest/configuration?name=eum.es.host\&value=http://appd-loadbalancer:9080
curl --user root@system:root -X POST http://localhost:8090/controller/rest/configuration?name=appdynamics.on.premise.event.service.url\&value=http://appd-loadbalancer:9080
curl --user root@system:root -X POST http://localhost:8090/controller/rest/configuration?name=analytics.agentless.event.service.url\&value=http://localhost:9080

ES_KEY=`curl --user root@system:root http://localhost:8090/controller/rest/configuration?name=appdynamics.es.eum.key | grep value |  sed "s@\s*<value>\(.*\)</value>\s*@\1@"`
echo "ES_KEY=$ES_KEY"
ssh -o StrictHostKeyChecking=no appd-eum sed -i "s/analytics\.accountAccessKey=.*/analytics.accountAccessKey=$ES_KEY/" /home/appdynamics/EUM/eum-processor/bin/eum.properties
ssh -o StrictHostKeyChecking=no appd-eum sed -i "s/analytics\.serverHost=.*/analytics.serverHost=appd-loadbalancer/" /home/appdynamics/EUM/eum-processor/bin/eum.properties
ssh -o StrictHostKeyChecking=no appd-eum sed -i "s/analytics\.port=.*/analytics.port=9080/" /home/appdynamics/EUM/eum-processor/bin/eum.properties
ssh -o StrictHostKeyChecking=no appd-eum /home/appdynamics/start-eum.sh

tail -f /dev/null
