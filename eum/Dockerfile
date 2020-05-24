FROM alpine:3.11 as builder


RUN apk update; apk add --no-cache curl jq

#The document on downloading AppDynamics agents can be found here for referene
#https://docs.appdynamics.com/display/PRO45/Download+AppDynamics+Software

ARG username
ARG password

RUN if [ "$username" == "" ] || [ "$password" == "" ]; then echo "No arg set. Set build arg: docker-compose build --build-arg username=xxx --build-arg password=xx"; exit 1; fi

RUN TOKEN=`curl -X POST -d "{\"username\": \"$username\", \"password\": \"$password\", \"scopes\": [\"download\"]}" https://identity.msrv.saas.appdynamics.com/v2.0/oauth/token  |  jq '.access_token' --raw-output` && if [ $TOKEN == "null" ]; then echo "Username or password might be wrong !"; exit 1; fi && \
DOWNLOAD_METADATA=`curl https://download.appdynamics.com/download/downloadfilelatest/` && \
DOWNLOAD_PATH=`echo $DOWNLOAD_METADATA | jq 'map(select(.title == "EUM Server - 64-bit linux (sh)"))[0].download_path' --raw-output` && curl -L -O -H "Authorization: Bearer $TOKEN" $DOWNLOAD_PATH

FROM centos:7

RUN yum -y install libaio numactl
RUN yum -y install which
RUN yum -y install openssh-server
RUN yum clean all

RUN systemctl enable sshd

RUN sed -ri 's/^(root):[^:]*:(.*)$/\1:*:\2/' /etc/shadow

EXPOSE 22

RUN groupadd appdynamics && useradd -m -g appdynamics appdynamics
USER appdynamics
WORKDIR /home/appdynamics

COPY id_rsa.pub .
RUN mkdir -p ~/.ssh; cat id_rsa.pub >> ~/.ssh/authorized_keys
RUN chmod 600 ~/.ssh/authorized_keys

COPY --from=builder --chown=appdynamics:appdynamics /euem-64bit-linux-*.sh /home/appdynamics/euem-64bit-linux.sh
#RUN chown appdynamics /home/appdynamics/euem-64bit-linux.sh; chmod +x /home/appdynamics/euem-64bit-linux.sh
RUN chmod +x /home/appdynamics/euem-64bit-linux.sh

COPY response.varfile .

# 1. Install EUM
RUN /home/appdynamics/euem-64bit-linux.sh -q -varfile response.varfile

# 2. For Prod mode, uncomment below to change Xms Java heap to 4GB
#RUN sed -i "s/Xms1024m/Xms4096m/" /home/appdynamics/EUM/eum-processor/bin/eum-processor

# 3. Provision EUM license
COPY license.lic .
# Start EUM MySQL (prereq to provision license)
RUN export JAVA_HOME=/home/appdynamics/EUM/jre; cd /home/appdynamics/EUM/orcha/orcha-master/bin; ./orcha-master -d mysql.groovy -p ../../playbooks/mysql-orcha/start-mysql.orcha -o ../conf/orcha.properties -c local; cd /home/appdynamics/EUM/eum-processor; ./bin/provision-license ~/license.lic

COPY --chown=appdynamics:appdynamics start-eum.sh .
RUN chmod +x start-eum.sh

USER root
ENTRYPOINT /sbin/init
