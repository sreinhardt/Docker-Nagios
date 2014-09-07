#start with my centos build
FROM sreinhardt/centos-6-x86_64:latest

MAINTAINER Spenser Reinhardt
ENV nagios_version 4.0.8
ENV nagios_user nagios
ENV nagios_group nagios
ENV nagcmd_group nagcmd
ENV plugins_version 2.0.3

#dependencies
RUN yum install -y wget httpd php gcc glibc glibc-common gd gd-devel make net-snmp

#users and groups
RUN groupadd ${nagcmd_group}
RUN useradd ${nagios_user} -s /bin/false -M -d /usr/local/nagios/ -U -G ${nagcmd_group}
RUN usermod -a -G ${nagcmd_group} apache
RUN usermod -a -G ${nagios_group} apache

#copy and build core
WORKDIR /tmp/
ADD https://github.com/NagiosEnterprises/nagioscore/archive/nagios-${nagios-version}.tar.gz /tmp/nagios-${nagios-version}.tar.gz
RUN tar xzvf nagios-${nagios-version}.tar.gz
RUN ls -lart; pwd
WORKDIR nagios-${nagios-version}/
RUN ./configure --with-command-group=${nagcmd_group} --with-nagios-group=${nagios_group}
RUN make
RUN make all
RUN make install
RUN make install-init
RUN make install-config
RUN make install-commandmode
RUN make install-webconf
RUN cp -R contrib/eventhandlers/ /usr/local/nagios/libexec/
RUN chown -R nagios:nagios /usr/local/nagios/libexec/eventhandlers
RUN /usr/local/nagios/bin/nagios -v /usr/local/nagios/etc/nagios.cfg

#copy and build plugins
WORKDIR /tmp/
ADD https://github.com/nagios-plugins/nagios-plugins/archive/release-${plugins-version}.tar.gz /tmp/nagios-plugins-${plugins-version}.tar.gz
RUN tar xzvf nagios-plugins-${plugins_version}.tar.gz
RUN ls -lart; pwd
WORKDIR nagios-plugins-${plugins_version}/
RUN ./configure --with-nagios-user=${nagios_user} --with-nagios-group=${nagios_group}
RUN make
RUN make install

ADD nagioscore.sh /etc/init.d/nagioscore

#Post-build docker info
EXPOSE 80
EXPOSE 443
WORKDIR /usr/local/nagios/
CMD ["/etc/init.d/nagioscore", "-s default"]
