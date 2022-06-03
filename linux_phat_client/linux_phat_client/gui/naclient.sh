MACROF=/opt/sslvpn-plus/naclient/macro.sh
LOGF=/tmp/naclient.log
if [ -f $LOGF ] ; then  
	rm -f $LOGF
fi

if [ ! -f $MACROF ] ; then  
	echo "file $MACROF is not present" >> $LOGF
	exit 1
fi
. $MACROF 

if [ ! -d $GDIR ] ; then 
	echo " $GIDR does not exist" >> $LOGF
	exit 1 
fi 
cd $GDIR
RETVAL=$?
if [ $RETVAL -ne 0 ] ; then 
	echo " Unable to chage directort to $GDIR " >> $LOGF
	exit 1
fi

if [ ! -f $ERROR_GF ] ; then  
	echo "file $ERROR_GF is not present" >> $LOGF
	exit 1
fi

#(/sbin/lsmod | grep $CHAR_DEV) > /dev/null
#RETVAL=$?
#if [ $RETVAL -ne 0 ] ; then
#	wish $ERROR_GF Error: SSL VPN-Plus Client is not running 
#	exit 0 
#fi

#if [ ! -c /dev/$CHAR_DEV ] ; then
#	 exec wish $ERROR_GF Error: /dev/$CHAR_DEV does not exist
#	 exit 0	
#fi 

# checks for error macro file file
if [ ! -f $ERROR_CODEF ] ; then 
	$ERROR_GF Error: file $ERROR_CODEF is not present
	exit 0
fi
if [ ! -s $ERROR_CODEF ] ; then
	$ERROR_GF Error: file $ERROR_CODEF is empty 
	exit 0
fi 
. $ERROR_CODEF 


# user file 
if [ ! -f $USERF ] ; then
	wish $ERROR_GF Error: $USERF file is not present
	exit 0
fi
if [ ! -s $USERF  ] ; then
	wish $ERROR_GF Error: $USERF file is empty
	exit 0
fi
if [ ! -x $USERF  ] ; then
	wish $ERROR_GF Error: $USERF file is present but it is not an executable file
 	exit 0
fi

# user gui file 
if [ ! -f $USER_GF ] ; then
	wish $ERROR_GF Error: $USER_GF file is not present
 	exit 0
fi
if [ ! -s $USER_GF  ] ; then
	wish $ERROR_GF Error: $USER_GF file is empty
 	exit 0
fi
if [ ! -x $USER_GF  ] ; then
	wish $ERROR_GF Error: $USER_GF file is present but it is not an executable file
 	exit 0
fi

CHECK=`pstree -a | grep "wish /opt/sslvpn-plus/naclient/gui"|grep -v grep | wc -l`
if [ $CHECK -gt 0 ] ; then
	exit 0
fi

#$USERF -gui -check
/usr/local/bin/naclient status >/dev/null 2>&1
RETVAL=$?
if [ $RETVAL -eq $BBERR_INVALID_USER ] ; then
	wish  $ERROR_GF Error: Another user connected to gateway, only that user/root has permission to see connection statistics or to logout from gateway 
	exit 0 
fi

if [ $RETVAL -eq 1 ] ; then 
	# statistics/logout gui file 
#	if [ ! -f $STATUS_GF ] ; then
#		wish $ERROR_GF Error: $STATUS_GF file is not present
# 		exit 0
#	fi
#	if [ ! -s $STATUS_GF  ] ; then
#		wish $ERROR_GF Error: $STATUS_GF file is empty
# 		exit 0
#	fi
#	$USERF -gui -status
/usr/local/bin/naclient guistatus
else
	# login gui file 
	if [ ! -f $GUI_GF ] ; then
		wish $ERROR_GF Error: $GUI_GF file is not present
 		exit 0
	fi
	if [ ! -s $GUI_GF  ] ; then
		wish $ERROR_GF Error: $GUI_GF file is empty
	 	exit 0
	fi
	# main configuration  file
	if [ ! -f $MAIN_CONF ] ; then
		wish $ERROR_GF Error: $MAIN_CONF file is not present
 		exit 0
	fi
	if [ ! -s $MAIN_CONF  ] ; then
		wish $ERROR_GF Error: $MAIN_CONF file is empty
 		exit 0
	fi
	
	/usr/local/bin/naclient status
        RETVAL=$?
        if [ $RETVAL -eq $BB_ALREADY_STOPPED ] ; then
	#	wish $ERROR_GF ERROR: no connection to gw exists
#		wish /opt/sslvpn-plus/naclient/gui/mesg "disconnected from gateway for some reason"
		tclsh ./errrr3
		#wish $GUI_GF
	else
		wish $GUI_GF
	fi
fi 


