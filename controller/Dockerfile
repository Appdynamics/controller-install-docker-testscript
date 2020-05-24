FROM centos:7

RUN yum -y install libaio numactl tzdata ncurses-libs-5.x
RUN yum -y install which
RUN yum -y install openssh-server openssh-clients
RUN yum clean all

#RUN sed -ri 's/^#PermitRootLogin yes/PermitRootLogin yes/' /etc/ssh/sshd_config
#RUN sed -ri 's/^UsePAM yes/UsePAM no/' /etc/ssh/sshd_config

RUN systemctl enable sshd

RUN sed -ri 's/^(root):[^:]*:(.*)$/\1:*:\2/' /etc/shadow

EXPOSE 22

RUN groupadd appdynamics && useradd -m -g appdynamics appdynamics
USER appdynamics
WORKDIR /home/appdynamics

COPY id_rsa.pub .
RUN mkdir -p /home/appdynamics/.ssh; cat id_rsa.pub >> ~/.ssh/authorized_keys
RUN chmod 600 ~/.ssh/authorized_keys

USER root
ENTRYPOINT /sbin/init
