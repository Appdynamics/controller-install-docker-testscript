FROM centos:7

RUN yum -y install epel-release
RUN yum -y install nginx

RUN yum clean all

COPY eventservice.conf /etc/nginx/conf.d/eventservice.conf

EXPOSE 9080

STOPSIGNAL SIGTERM

CMD ["nginx", "-g", "daemon off;"]

