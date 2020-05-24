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

tail -f /dev/null
