#start with ubuntu
FROM sreinhardt/centos-6-x86_64:latest

MAINTAINER Spenser Reinhardt

#copy and build
WORKDIR /tmp/
ADD http://assets.nagios.com/downloads/nagiosxi/xi-latest.tar.gz xi-latest.tar.gz
RUN tar xzvf xi-latest.tar.gz
WORKDIR nagiosxi/
RUN ./fullinstall -n

#include init script
ADD nagiosxi.sh /etc/init.d/nagiosxi

#Post-build docker info
EXPOSE 80
EXPOSE 443
EXPOSE 5667

WORKDIR /usr/local/nagios/
CMD ["/etc/init.d/nagiosxi", "-s default -l /var/log/nagiosxi.log"]
