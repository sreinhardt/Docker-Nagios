#start with our centos base
FROM sreinhardt/centos-6-x86_64:latest

MAINTAINER Spenser Reinhardt

#copy and build
WORKDIR /tmp/
ADD http://assets.nagios.com/downloads/nagios-network-analyzer/nagiosna-latest.tar.gz /tmp/nagiosna-latest.tar.gz
RUN tar xzvf nagiosna-latest.tar.gz
WORKDIR nagiosna/
RUN ./fullinstall -n
ADD nagiosna.sh /etc/init.d/nagiosna-services
RUN ln -s /usr/local/nagiosna/bin/nagiosna /etc/init.d/nagiosna

#Post-build docker info
EXPOSE 80
EXPOSE 443

WORKDIR /usr/local/nagiosna/
CMD ["/etc/init.d/nagiosna-services", "-s default"]
