#!/bin/bash
### BEGIN INIT INFO
# Provides:          naclient
# Required-Start:    $remote_fs $syslog
# Required-Stop:     $remote_fs $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Start at boot time
# Description:       Enable service provided by daemon.
### END INIT INFO
MACRO_FILE=/opt/sslvpn-plus/naclient/macro.sh
DAEMON=/opt/sslvpn-plus/naclient/naclientd
CLIENTD=/opt/sslvpn-plus/naclient/naclientd
RELFILE=/etc/redhat-release
TUNDEVICE=/dev/net/tun
if [ ! -f $MACRO_FILE ] ; then
	echo "Error: $MACRO_FILE is not present"
	exit  
fi

if [ ! -s $MACRO_FILE ] ; then 
	echo "Error: file $MACRO_FILE is empty" 	
	exit  0
fi
.  $MACRO_FILE

if [ ! -d $DIR ] ; then
	echo "$DIR directory is not present"
 	exit 0
fi

if [ ! -f $RELFILE ] ; then
    RELEASE="DEBIAN"
else
    RELEASE="REDHAT"
fi

if [ $RELEASE = "DEBIAN" ] ; then
	echo_success() {
		echo ' [   OK   ] '
	}

	echo_failure() {
		echo ' [ FAILED ] '
	}
else
	# Source function library.
	. /etc/rc.d/init.d/functions

	# Source networking configuration.
	. /etc/sysconfig/network

	# Check that networking is up.
	if [ ${NETWORKING} = "no" ] ; then 
		echo $"System network is not configured"
		exit 0
	fi
fi


if [ ! -f $INSTALL_CONF ] ; then
	echo "$INSTALL_CONF file is not present"
 	exit 0
fi

if [ ! -s $INSTALL_CONF ] ; then
	echo " $INSTALL_CONF file is empty"
 	exit 0
fi

# Neoaccel Client configuration.
. $INSTALL_CONF


RETVAL=0
prog=$CLIENT

stopdaemon(){
    echo "Error in loading $TUNDEVICE"
    echo "Stopping $CLIENTD daemon ..."
    (set `ps -aux | grep $CLIENTD | tr -s ' ' | cut -d' ' -f2 `; kill -9 $1  ) > /dev/null 2>&1
    kill -9 $1 > /dev/null 2>&1
    echo "Stopping $POLLD  ..."
    (set `ps -aux | grep $POLLD | tr -s ' ' | cut -d' ' -f2 `; kill -9 $1  ) > /dev/null 2>&1
    kill -9 $1 > /dev/null 2>&1
}

checkstatus() {
	if [ $RELEASE = "DEBIAN" ] ; then
	    VALUE=`pstree | grep naclientd | wc -l`
            VALUE1=`pstree | grep naclient_poll | wc -l`
            if [ $VALUE -eq 0 -a $VALUE1 -eq 0 ] ; then
			RETVAL=1
		else
			RETVAL=0
	    fi
	else
		CHECK_1=` pidof $CLIENTD`
		CHECK_2=` pidof $POLLD`
		if [ -z $CHECK_1 -a -z $CHECK_2 ] ; then
			RETVAL=1
		else
			RETVAL=0
		fi
		#CHECK=`status $CLIENTD | cut -d ' ' -f 3`
		#echo " $CHECK "
	    #if [ $CHECK = "stopped" ] ; then
        #	RETVAL=1
       # else
        #    RETVAL=0
	 #   fi
	fi
    return $RETVAL
}


start() {
	(checkstatus)
		
	CHECK=$?
	if [ $CHECK -eq 0 ] ; then
		echo "Error: SSL VPN-Plus is already running"
		RETVAL=1
		return $RETVAL
	fi

	`lsmod | grep "tun " >/dev/null`
	RETVAL=$?

	if [ $RETVAL -ne 0 ] ; then
		modprobe tun
		RETVAL=$?
		if [ $RETVAL -ne 0 ] ; then
			(stopdaemon)
			return $RETVAL
		fi
	fi

	mknod /opt/sslvpn-plus/tun c 10 200

	$CLIENTD &>  /dev/null &
	RETVAL=$?
	if [ $RETVAL -ne 0 ] ; then
		echo "Error: Could not create client daemon process"
		return $RETVAL
	fi

	$POLLD & > /dev/null &
	RETVAL=$?
	if [ $RETVAL -ne 0 ] ; then
		echo "Error: Could not create $POLLD daemon process"
		echo "Stopping $CLIENTD daemon ..."
		(set `ps -aux | grep $CLIENTD | tr -s ' ' | cut -d' ' -f2 `; kill -9 $1  ) > /dev/null 2>&1

		kill -9 $1 > /dev/null 2>&1
		sleep 5
		return $RETVAL
	fi

#	if [ $RETVAL -eq 0 ] ; then
#		if [ ! -z "$COMMAND" ] ; then
#			VAL=`cat $MAIN_CONF | cut -d ' ' -f 3`
#				 PROFILEVALSTART=$(expr $(($VAL & 8)))				
#				if [ $PROFILEVALSTART -eq 8 ] ; then
#				sleep 12
#				$COMMAND
#				fi
#		fi
#	fi
	
	return $RETVAL 
 
}

stop() {
	(checkstatus)
	CHECK=$?
	if [ $CHECK -eq 1 ] ; then
		echo "Error: SSL VPN-Plus is stopped"
		RETVAL=1
		return $RETVAL
	fi

	if [ ! -f $USERF_LOGIN ] ; then 
		echo "Error: $USERF_LOGIN file does not exist"
		RETVAL=1
		return $RETVAL  
	fi

	if [ ! -x $USERF_LOGIN ] ; then 
		echo "Error: $USERF_LOGIN file exists but it is not excutable "
		RETVAL=1
		return $RETVAL  
	fi
	
#	VAL=`cat $MAIN_CONF | cut -d ' ' -f 3`
#	PROFILEVAL=$(expr $(($VAL & 8))) 
	
#	if [ $PROFILEVAL -eq 8 ] ; then
#	$DIR/login logout
#	fi

	echo "Stopping $POLLD daemon ..."
	killall -9 $POLLD &> /dev/null &
	sleep 1
	
	ifconfig tap0 &> /dev/null >&1
	RETVAL=$?
	if [ $RETVAL -eq 0 ] ; then
		echo "Logging out from gateway ..."	
		$USERF_LOGIN logout  &> /dev/null
		RETVAL=$?
                # RETVAL 1 = logot successfull, 4 = client was not logged in
		if [ $RETVAL -ne 1 -a $RETVAL -ne 4 ] ; then
			echo "Error: Could not logged out from gateway "	
			RETVAL=1
		fi
	fi

	echo "Stopping $CLIENTD daemon ..."
	killall -9 $CLIENTD &> /dev/null &
	RETVAL=$? 
	sleep 1
	return $RETVAL

}

clientstatus() {
	(checkstatus)
	CHECK=$?
	if [ $CHECK -eq 1 ] ; then
		echo "SSL VPN-Plus Client is not running"
	else
		echo "SSL VPN-Plus Client is running ..."
	fi
}

# See how we were called.
case "$1" in
  start)
        start
	echo -n $"Starting SSL VPN-Plus			"
	[ $RETVAL -eq  0 ] && echo_success
	[ $RETVAL -ne  0 ] && echo_failure
	echo
        ;;

  stop)
        stop
	echo -n $"Stopping SSL VPN-Plus			"
	[ $RETVAL -eq  0 ] && echo_success
	[ $RETVAL -ne  0 ] && echo_failure
	echo
        ;;

  restart|reload)
        stop
        start
        RETVAL=$?
	echo -n $"Restarting SSL VPN-Plus		"
	[ $RETVAL -eq  0 ] && echo_success
	[ $RETVAL -ne  0 ] && echo_failure
	echo
        ;;
	status)
		clientstatus
		;;	
		
  *)
        echo $"Usage: $0 {start|stop|restart|status}"
        exit 1
esac

