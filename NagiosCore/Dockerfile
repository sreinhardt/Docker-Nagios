# Start with my centos build
FROM sreinhardt/centos-6-x86_64:latest

MAINTAINER Spenser Reinhardt

# Global variables
ENV nagios_version 4.0.8
ENV plugins_version 2.0.3
ENV nagios_user nagios
ENV nagios_group nagios
ENV nagcmd_group nagcmd


# Dependencies
RUN yum install -y wget httpd php gcc glibc glibc-common gd gd-devel make net-snmp

# Users and groups
RUN groupadd ${nagcmd_group}
RUN useradd ${nagios_user} -s /bin/false -M -d /usr/local/nagios/ -U -G ${nagcmd_group}
RUN usermod -a -G ${nagcmd_group} apache
RUN usermod -a -G ${nagios_group} apache

# Copy and untar core
WORKDIR /tmp/
ADD https://github.com/NagiosEnterprises/nagioscore/archive/nagios-${nagios_version}.tar.gz /tmp/nagios-${nagios_version}.tar.gz
RUN tar xzvf nagios-${nagios_version}.tar.gz

# Change per version
WORKDIR nagioscore-nagios-4.0.8/

# Build core
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

# Copy and untar plugins
WORKDIR /tmp/
ADD https://github.com/nagios-plugins/nagios-plugins/archive/release-${plugins_version}.tar.gz /tmp/nagios-plugins-${plugins_version}.tar.gz
RUN tar xzvf nagios-plugins-${plugins_version}.tar.gz

# Change per version
WORKDIR nagios-plugins-release-2.0.3/

# Build plugins
RUN ls -lart; pwd
RUN ./tools/setup
RUN ./configure --with-nagios-user=${nagios_user} --with-nagios-group=${nagios_group}
RUN make
RUN make install

# Add multi-service startup script
ADD nagioscore.sh /etc/init.d/nagioscore

# Post-build docker info
EXPOSE 80
EXPOSE 443
WORKDIR /usr/local/nagios/
CMD ["/etc/init.d/nagioscore", "-s default"]
