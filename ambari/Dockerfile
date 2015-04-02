FROM lresende/ambari-node:1.0

MAINTAINER Luciano Resende <lresende@apache.org>

USER root

# Clean metadata to avoid 404 erros from yum
RUN yum clean all

# ambari
ADD etc/yum.repos.d/ambari.repo /etc/yum.repos.d/ambari.repo

# ambari server setup
RUN yum -y install ambari-server
RUN ambari-server setup --silent

# Patch AMBARI-8620
RUN cd /usr/lib/ambari-server/web/javascripts/ && gunzip app.js.gz
RUN sed -i.bak "s@].contains(mPoint@, '/etc/resolv.conf', '/etc/hostname', '/etc/hosts'].contains(mPoint@g" /usr/lib/ambari-server/web/javascripts/app.js
RUN cd /usr/lib/ambari-server/web/javascripts/ && gzip -9 app.js

# workaround for port issues over vpn
RUN echo "client.api.port=8081" >> /etc/ambari-server/conf/ambari.properties

# ambari agent
RUN yum -y install ambari-agent
ADD etc/ambari-agent/ambari-agent.ini /etc/ambari-agent/conf/ambari-agent.ini

# bootstrap config
ADD bootstrap.sh /etc/bootstrap.sh
RUN chown root:root /etc/bootstrap.sh
RUN chmod 700 /etc/bootstrap.sh

ENV BOOTSTRAP /etc/bootstrap.sh

EXPOSE 2122 10000 11000 50010 50020 50030 50070 50075 50090 50111 60010 8000 8020 8021 8081 8088 8440 8441 8670 8888

CMD ["/etc/bootstrap.sh", "-d"]
