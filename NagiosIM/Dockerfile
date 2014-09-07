#start with my centos build
FROM sreinhardt/centos-6-x86_64:latest

MAINTAINER Spenser Reinhardt

#copy and build
WORKDIR /tmp/
ADD http://assets.nagios.com/downloads/nagiosim/nagiosim-latest.tar.gz /tmp/nagiosim-latest.tar.gz
RUN tar xzvf nagiosim-latest.tar.gz
WORKDIR nagiosim/
RUN ./fullinstll -n

ADD nagiosim.sh /etc/init.d/nagiosim

#Post-build docker info
EXPOSE 80
EXPOSE 443
WORKDIR /usr/local/nagiosim/
CMD ["/etc/init.d/nagiosim", "-s default"]
