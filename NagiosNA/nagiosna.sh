#!/bin/bash

# Created by: Spenser Reinhardt
# License: GPLv2

# Global vars
logfile="/var/log/nagiosna.log"
tarball="http://assets.nagios.com/downloads/nagios-network-analyzer/nagiosna.latest.tar.gz"
default_services_start="mysqld httpd nagiosna"
default_services_stop="nagiosna httpd mysqld"

usage() {
cat <<EOF

Usage: ${0} [options]

This script is intended start and stop a variety of services in a docker container. While not very docker-ish, it does server a porpouse.
Also has the ability to upgrade Nagios products.

Options:
	-h	This output.
	-s	Service to start. May be used multiple times, services will be started in given order.
		(Default: ${default_services_start})
	-l	Log file to store output from this script. (Default: ${logfile})
	-u	Update Nagios installation

EOF
}

# Start $service in $services(global)
start-services() {
	IFS_temp="${IFS}"
	IFS=" "

	for service in ${services}; do

		# Validate service exists in init.d
		if [[ ! -f "${initdir}/${service}" ]]; then
			echo Service ${service} is not available 2>&1 | tee -a "${logfile}"
			exit 3
		fi
		# Validate current service status
		if [[ $("${initdir}/${service}" status) -eq 0 ]]; then
			echo Service ${service} already started, skipping 2>&1 | tee -a "${logfile}"
			continue
		fi
		# service was not started, start it
		if [[ $("${initdir}/${service}" start) -ne 0 ]]; then
			echo Service ${service} was unable to start 2>&1 | tee -a "${logfile}"
			exit 3
		else
			echo Service ${service} started successfully 2>&1 | tee -a "${logfile}"
		fi
	done

	IFS="${IFS_temp}"
	echo Done starting ${services} 2>&1 tee -a "${logfile}"
}

# Stop $service in $services(global).
stop-services() {
	IFS_temp="${IFS}"
	IFS=" "

	for service in ${services}; do

		# Validate service exists in init.d
		if [[ ! -f "${initdir}/${service}" ]]; then
			echo Service ${service} is not available 2>&1 | tee -a "${logfile}"
			exit 4
		fi
		# Validate current service status
		if [[ $("${initdir}/${service}" status) -ne 0 ]]; then
			echo Service ${service} is already stopped 2>&1 | tee -a "${logfile}"
			continue
		fi
		# service is running, stop it
		if [[ $("${initdir}/${service}" stop) -ne 0 ]]; then
			echo Service ${service} could not be stopped, continuing 2>&1 | tee -a "${logfile}"
		else
			echo Service ${service} was stopped successfully 2>&1 | tee -a "${logfile}"
		fi
	done

	IFS="${IFS_temp}"
	echo Done stopping ${services} 2>&1 | tee -a "${logfile}"
}

# Update product(s)
update() {
	cd /tmp/
	wget "${tarball}" 2>&1 | tee -a "${logfile}.upgrade"
	if [[ ${PIPESTATUS[0]} -ne 0 ]]; then
		echo Failed to download tarball, exiting. 2>&1 | tee -a "${logfile}.upgrade"
		exit 5
	fi

	tar xvzf xi-latest.tar.gz 2>&1 | tee -a "${logfile}.upgrade"
	if [[ ${PIPESTATUS[0]} -ne 0 ]]; then
		echo Failed to extract tarball, exiting. 2>&1 | tee -a "${logfile}.upgrade"
		exit 5
	fi

	cd nagiosxi/
	./upgrade 2>&1 | tee -a "${logfile}.update"
	if [[ ${PIPESTATUS[0]} -ne 0 ]]; then
		echo Failed to properly run upgrade script, exiting. 2>&1 | tee -a "${logfile}.upgrade"
		exit 5
	fi
	
	echo Finished upgrade, exiting. 2>&1 | tee -a "${logfile}.upgrade"
}

# Handle cli arguments
getargs() {
	while getopts "hux:s:l:" opt; do
		case ${opt} in
			h)
				usage
				exit 0
				;;
			s)
				if [[ -z $services ]]; then
					services="$OPTARG"
				else
					service=" $OPTARG"
				fi
				;;
			l)
				logfile="$OPTARG"
				;;
			u)
				update=${true}
				;;
			x)
				stop=${true}
			?)
				usage
				exit 1
				;;
		esac
	done

	if [[ -z $stop ]]; then
		stop=${false}
	fi
	if [[ -z $update ]]; then
		update=${false}
	fi
	# Catch not updating and no services
	if [[ ${update} -eq ${false} ]] && [[ -z $services ]]; then
		echo You must set services to start or update flag, exiting 2>&1 tee -a ${logfile}
		usage
		exit 2
	fi
	# Catch if we just eant default services for this image type
	if [[ ${update} -eq ${false} ]] && [[ ${stop} -eq ${false} ]] && [[ "$services" -eq "default" ]]; then
		services="${default_services_start}"
	elif [[ ${update} -eq ${false} ]] && [[ ${stop} -eq ${true} ]] && [[ "$services" -eq "default" ]]; then
		services="${default_services_stop}"
	fi

}

# main logic
getargs

if [[ ${upgrade} -eq ${true} ]]; then
	services="${default_services_start}"
	start-services
	upgrade
	exit 0
fi

if [[ ${stop} -eq ${true} ]]; then
	stop-services
	exit 0
else
	start-services
	# Need to sleep forever since docker watches the first process only, and we want services to actually run
	sleep infinity
fi
