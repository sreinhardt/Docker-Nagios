#start with my centos build
FROM sreinhardt/centos-6-x86_64:latest

MAINTAINER Spenser Reinhardt

#copy and build
WORKDIR /tmp
ADD http://assets.nagios.com/downloads/nsti/tarballs/latest.php /tmp/nsti.tar.gz
RUN tar xzvf nsti.tar.gz
WORKDIR nsti-*/
RUN sh install.sh

ADD nagiossti.sh /etc/init.d/nagiossti

#Post-build docker info
EXPOSE 80
EXPOSE 162
EXPOSE 443
EXPOSE 8080

WORKDIR /usr/local/nagiossti/
CMD ["/etc/init.d/nagiossti", "-s default"]
