FROM alpine:3.11 as builder


RUN apk update; apk add --no-cache curl jq

#The document on downloading AppDynamics agents can be found here for referene
#https://docs.appdynamics.com/display/PRO45/Download+AppDynamics+Software

ARG username
ARG password

RUN if [ "$username" == "" ] || [ "$password" == "" ]; then echo "No arg set. Set build arg: docker-compose build --build-arg username=xxx --build-arg password=xx"; exit 1; fi

RUN TOKEN=`curl -X POST -d "{\"username\": \"$username\", \"password\": \"$password\", \"scopes\": [\"download\"]}" https://identity.msrv.saas.appdynamics.com/v2.0/oauth/token  |  jq '.access_token' --raw-output` && if [ $TOKEN == "null" ]; then echo "Username or password might be wrong !"; exit 1; fi && \
DOWNLOAD_METADATA=`curl https://download.appdynamics.com/download/downloadfilelatest/` && \
DOWNLOAD_PATH=`echo $DOWNLOAD_METADATA | jq 'map(select(.title == "Enterprise Console - 64-bit linux (sh)"))[0].download_path' --raw-output` && curl -L -O -H "Authorization: Bearer $TOKEN" $DOWNLOAD_PATH

RUN ls -ltr

FROM centos:7

RUN yum -y install libaio numactl tzdata ncurses-libs-5.x
RUN yum -y install which
RUN yum -y install openssh-clients
RUN yum clean all

RUN groupadd appdynamics && useradd -m -g appdynamics appdynamics
COPY --from=builder /platform-setup-x64-linux-*.sh /home/appdynamics/platform-setup-64bit-linux.sh

RUN chown appdynamics /home/appdynamics/platform-setup-64bit-linux.sh; chmod +x /home/appdynamics/platform-setup-64bit-linux.sh
USER appdynamics
WORKDIR /home/appdynamics

ADD response.varfile .
RUN chmod +x ./platform-setup-64bit-linux.sh
RUN ./platform-setup-64bit-linux.sh -q -varfile response.varfile

COPY --chown=appdynamics:appdynamics entrypoint*.sh ./
RUN chmod +x entrypoint*.sh
COPY --chown=appdynamics:appdynamics id_rsa .
RUN mkdir -p ~/.ssh; cp id_rsa ~/.ssh/id_rsa; chmod 600 ~/.ssh/id_rsa

COPY --chown=appdynamics:appdynamics license.lic .

