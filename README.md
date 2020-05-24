# controller-install-docker-testscript

Install and run controller / event service / eum easily using Docker Compose.
This is not a supported way to install AppDynamics Controller , so please use only for your personal test.

### 1. Place your own license.lic under directories ec/ and eum/ .
### 2. Generate ssh keys to be installed in contollers later using below shell script. (Only work for Linxu and Mac)
```
./run-beforebuild.sh
```
### 3. Build using below format.

```
docker-compose build --build-arg username=<your appd email> --build-arg password=<password>
```

username and password is used to to automatically download installers from https://download.appdynamics.com/ .

### 3. Run using either of the below command

* docker-compose -f docker-compose.distributed.yml up
* docker-compose -f docker-compose.ec-controller-event-samehost.yml up
* docker-compose -f docker-compose.ec-controller-samehost.yml up

### 4. Access the Controller 
Access http://localhost:8090 to your controller.
Login credential is admin/admin or root/root.
