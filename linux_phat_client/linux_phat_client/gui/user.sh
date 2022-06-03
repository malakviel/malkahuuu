MACRO_FILE=/opt/sslvpn-plus/naclient/macro.sh
if [ ! -f $MACRO_FILE ] ; then
	echo "Error: $MACRO_FILE is not present"
	exit  
fi

if [ ! -s $MACRO_FILE ] ; then 
	echo "Eroor: file $MACRO_FILE is empty" 	
	exit  0
fi
.  $MACRO_FILE

if [ `pwd` != $GDIR ] ; then
	ENV="cli"
else
	ENV="gui"
fi

mesg() {
	if [ $ENV = "gui" ] ; then
		wish $ERROR_GF	$1
	else
		echo $1
	fi
}

valid_ip_hostname()
{
    ip=$1
    echo $ip | egrep "^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$"
    if [ $? -eq "0" ]; then
        oldIFS=$IFS
        IFS=.
        set -- $ip
        IFS=$OIFS
        for oct in $1 $2 $3 $4; do
            if [ "$oct" -lt "0" -o "$oct" -gt "255" ]; then
#               echo "$oct: Out of range"
                return 1
            fi
        done
#        echo "$ip validates OK!"
        return 0
    else
        ValidHostnameRegex="^\(\([a-zA-Z0-9]\|[a-zA-Z0-9][a-zA-Z0-9\\-]*[a-zA-Z0-9]\)\\.\)*\([A-Za-z0-9]\|[A-Za-z0-9][A-Za-z0-9\\-]*[A-Za-z0-9]\)$"
        name=$1

        if echo $name | grep "$ValidHostnameRegex"
        then
#               echo "valid" 
                return 0
        else
#               echo invalid 
                return 1
        fi

    fi
}
# checks for error macro file file
if [ ! -f $ERROR_CODEF ] ; then 
	mesg "Error: file $ERROR_CODEF is not present"
	exit 0
fi
if [ ! -s $ERROR_CODEF ] ; then
	mesg "Error: file $ERROR_CODEF is empty" 
	exit 0
fi 
. $ERROR_CODEF 


# checks for user excutable file
if [ ! -f $USERF ] ; then
	mesg "Error: $USERF file is not present"
 	exit 0
fi

if [ ! -s $USERF  ] ; then
	mesg "Error: $USERF file is empty"
 	exit 0
fi

if [ ! -x $USERF  ] ; then
	mesg "Error: $USERF file is present but it is not executable"
 	exit 0
fi

ARGV=$2
ARGV1=$1
ARGV2=$2
ARGV3=$3
RETVAL=0

RETVAL=`pstree | grep naclient | wc -l`
if [ $RETVAL -eq 0 ] ; then
	mesg "Error: SSL VPN-Plus Client is not running" 
	exit 0 
fi

connected() {
#	$USERF -idle_timeout cli &
	mesg "Successfully Connected to  SSL VPN-Plus Gateway" 
}

authpap_gui(){
	# Check for auth gui file		
	if [ ! -f $AUTH_GF ] ; then
		mesg "Error: $AUTH_GF file is not present"
		exit 0
	fi
	if [ ! -s $AUTH_GF ] ; then
		mesg "Error: $AUTH_GF file is empty"
 		exit 0
	fi
	wish $AUTH_GF 

}

proxy_auth_gui(){
	# Check for auth gui file		
	if [ ! -f $PROXY_AUTH_GF ] ; then
		mesg "Error: $PROXY_AUTH_GF file is not present"
		exit 0
	fi
	if [ ! -s $PROXY_AUTH_GF ] ; then
		mesg "Error: $PROXY_AUTH_GF file is empty"
 		exit 0
	fi
	wish $PROXY_AUTH_GF  $1	

}

certkey_gui(){
	# checks for cert-key gui 
	if [ ! -f $CERT_KEY_GF ] ; then
		mesg "Error: $CERT_KEY_GF file is not present"
		exit 0
	fi
	if [ ! -s $AUTH_GF ] ; then
		mesg "Error: $CERT_KEY_GF file is empty"
 		exit 0
	fi

	wish $CERT_KEY_GF 

}

upgrade_gui() {
	# checks for upgrade gui 
	if [ ! -f $UPGRADE_GF ] ; then
		mesg "Error: $UPGRADE_GF file is not present"
		exit 0
	fi
	if [ ! -s $UPGRADE_GF ] ; then
		mesg "Error: $UPGRADE_GF file is empty"
 		exit 0
	fi

	#wish $UPGRADE_GF
	/opt/sslvpn-plus/naclient/gui/user.sh upgrade no
}

err_ret_gui() {
	case $1 in 
	$BBERR_CLI_AUTH_REQD)
		certkey_gui
		exit 0
		;;

	$BB_STATUS_UPGRADE_REQUIRED)
		upgrade_gui
		exit 0  
		;;

	$BB_STATUS_AUTH_REQUIRED)
		authpap_gui
		exit 0
		;;
	50)
		proxy_auth_gui $2
		exit 0
		;;

	$BB_STATUS_RUNNING)
		connected
		exit 0
		;;

	$BB_STATUS_HOSTSCAN_REQUIRED)
		hostscan
		exit 0
		;;

	*)
		exit 0
		;;
	esac
}

err_ret_cli() {
	case $1 in 
	$BBERR_CLI_AUTH_REQD)
		cert
		exit 0
		;;

	$BB_STATUS_UPGRADE_REQUIRED)
		upgrade
		exit 0  
		;;

	$BB_STATUS_AUTH_REQUIRED)
		authpap
		exit 0
		;;

	$BB_STATUS_RUNNING)
		connected
		exit 0
		;;

	$BB_STATUS_HOSTSCAN_REQUIRED)
		hostscan
		exit 0
		;;

	*)
		exit 0
		;;
	esac
}




cert() {
	if [ $ENV = "gui" ] ; then 
		CERTFILE=$1
		KEYFILE=$2

	else
		echo "Client certificate based authentication required"
		echo -e "Enter client ertificate file Path: \c"
		read CERTFILE
		if [ -z $CERTFILE ] ; then
			cert
		fi
		echo -e "Enter key file Path: \c"
		read KEYFILE
		if [ -z $KEYFILE ] ; then
			KEYFILE=$CERTFILE 
		fi
	fi

	if [ ! -f $CERTFILE ] ; then
		mesg "Error: $CERTFILE file is not present"
		exit 0
	fi
	if [ ! -s $CERTFILE ] ; then
		mesg "Error: $CERTFILE file is empty"
		exit 0
	fi

	if [ ! -f $KEYFILE ] ; then
		mesg "Error: $KEYFILE file is not present"
		exit 0
	fi
	if [ ! -s $KEYFILE ] ; then
		mesg "Error: $KEYFILE file is empty"
		exit 0
	fi

	if [ $ENV = "gui" ] ; then 
		$USERF -gui -cert $CERTFILE $KEYFILE
	else
		$USERF -cli -cert $CERTFILE $KEYFILE
	fi 
	RETVAL=$?
	if [ $ENV = "gui" ] ; then 
		err_ret_gui $RETVAL 
	else
		err_ret_cli $RETVAL 
	fi
}


upgrade() {
	if [ $ENV = "gui" ] ; then 
		#$USERF -gui -upgrade $1 
		$USERF -gui -upgrade no 
	else
		#echo "New version of SSL VPN-Plus Client available"
		#echo -e "Do you want to upgrade (y/n): \c"
		#read choice
		#if [ $choice = "y" -o $choice = "Y" ] ; then
		#	$USERF -cli -upgrade yes
		#else
			$USERF -cli -upgrade no 
		#fi 
	fi
	RETVAL=$?
	if [ $ENV = "gui" ] ; then 
		err_ret_gui $RETVAL 
	else
		err_ret_cli $RETVAL 
	fi
}

hostscan() {
	if [ $ENV = "gui" ] ; then 
		$USERF -gui -hostscan  
	else
		$USERF -cli -hostscan 
	fi
	RETVAL=$?
	if [ $ENV = "gui" ] ; then 
		err_ret_gui $RETVAL 
	else
		err_ret_cli $RETVAL 
	fi
}


authpap() {
	if [ $ENV = "gui" ] ; then 
		$USERF -gui -authpap $1 $2
	else
		$USERF -cli -authpap 
	fi
	RETVAL=$?
	if [ $ENV = "gui" ] ; then 
		err_ret_gui $RETVAL 
	else
		err_ret_cli $RETVAL 
	fi
}

proxy_auth() {
	#check for install conf file	
	if [ ! -f $INSTALL_CONF ] ; then
		mesg "Error: $INSTALL_CONF file is not present"
	 	exit 0
	fi
	if [ ! -s $INSTALL_CONF ] ; then
		mesg "Error: $INSTALL_CONF file is empty"
 		exit 0
	fi
	. $INSTALL_CONF

	#check for main conf file	
	if [ ! -f $MAIN_CONF ] ; then
		mesg "Error: $MAIN_CONF file is not present"
 		exit 0
	fi

	if [ ! -s  $MAIN_CONF ] ; then
		mesg "Error: $MAIN_CONF file is empty"
 		exit 0
	fi

	ARGV1=$1
	ARGV2=$2
	ARGV3=$3
	set `grep -w $ARGV1 $MAIN_CONF`
	#$USERF -gui -login $VERSION $1 $2 $3 $4 $5 $6 $7 $8  $9 $ARGV2 $ARGV3
	mesg "this function is deprecated"
	RETVAL=$?
	if [ $RETVAL -eq 50 ] ; then 
		mesg "Error: Could not connect to proxy server"
		exit 0
	fi	
	err_ret_gui $RETVAL $1
}


login() {
	#check for install conf file	
	if [ ! -f $INSTALL_CONF ] ; then
		mesg "Error: $INSTALL_CONF file is not present"
	 	exit 0
	fi
	if [ ! -s $INSTALL_CONF ] ; then
		mesg "Error: $INSTALL_CONF file is empty"
 		exit 0
	fi
	. $INSTALL_CONF

	#check for main conf file	
	if [ ! -f $MAIN_CONF ] ; then
		mesg "Error: $MAIN_CONF file is not present"
 		exit 0
	fi

	if [ ! -s  $MAIN_CONF ] ; then
		mesg "Error: $MAIN_CONF file is empty"
 		exit 0
	fi

	#. $MAIN_CONF
	#ARGV2=$2
	#ARGV3=$3
	#set `grep -w $ARGV $MAIN_CONF`

	###RAJESH
	IPPORT=`cat $MAIN_CONF | grep $ARGV | cut -d ' ' -f 2`
	###RAJESH

	if [ $ENV = "gui" ] ; then 
		#$USERF -gui -login $MAC $ARGV $VERSION 192.168.10.219:445 
		mesg "this function is deprecated"
		#$USERF -gui -login $MAC $VERSION $ARGV $IPPORT
	else
		mesg "this function is deprecated"
		#$USERF -cli -login $MAC $VERSION $ARGV $IPPORT 
	fi
	RETVAL=$?
	if [ $ENV = "gui" ] ; then 
		err_ret_gui $RETVAL $1
	else
		err_ret_cli $RETVAL 
	fi
}


logout() {
	if [ $ENV = "gui" ] ; then 
		$USERF -gui -check
	else
		$USERF -cli -check
	fi
	RETVAL=$?

	if [ $RETVAL -eq $BBERR_INVALID_USER ] ; then
		mesg "Error: Another user is already logged in; only that user/root can logout" 
		exit 0 
	fi
	
	if [ $RETVAL -ne 1 ] ; then
		mesg "Error: There is no SSL Connection to Gateway"
		exit 0 
	fi
	echo "Logging out from gateway ..."	
	if [ $ENV = "gui" ] ; then 
		$USERF -gui -logout
	else
		$USERF -cli -logout
	fi
	RETVAL=$?
	case $RETVAL in 
	1)
		mesg "Successfully logged out from gateway"
		exit 0
		;;
	
	127)
		exit 0
		;;	
	*)
		mesg "Logout from SSL VPN-Plus Gateway : Failed "
		exit 0

	esac
	
}

status() {
	if [ $ENV = "gui" ] ; then 
		$USERF -gui -check
	else
		$USERF -cli -check
	fi
	RETVAL=$?
	if [ $RETVAL -eq $BBERR_INVALID_USER ] ; then
		mesg "Error: You do not have permission to see connection statistics" 
		exit 0 
	fi

	if [ $RETVAL -ne 1 ] ; then
		mesg "Error: There is no SSL Connection to Gateway"
		exit 0 
	fi
	if [ $ENV = "gui" ] ; then 
		$USERF -gui -status	
	else
		$USERF -cli -status	
	fi
}


setting() {
	if [ $ENV = "gui" ] ; then 
		$USERF -gui -check
	else
		$USERF -cli -check
	fi
	RETVAL=$?
	if [ $RETVAL -eq $BBERR_INVALID_USER ] ; then
		mesg "Error: You do not have permission to see connection setting" 
		exit 0 
	fi

	if [ $RETVAL -ne 1 ] ; then
		mesg "Error: There is no SSL Connection to Gateway"
		exit 0 
	fi


	if [ ! -f $PRIV_NETWORK_CONF ] ; then
		mesg "Error: $PRIV_NETWORK_CONF file is not present"
 		exit 0
	fi

	if [ ! -s  $PRIV_NETWORK_CONF ] ; then
		mesg "Error: $PRIV_NETWORK_CONF file is empty"
 		exit 0
	fi


	if [ $ENV = "gui" ] ; then 
		wish $SETTING_GF
	else
		cat $PRIV_NETWORK_CONF
		echo " "
	fi
	exit 0
}

add_profile() {
	
	#check for main conf file	
	if [ ! -f $MAIN_CONF ] ; then
		mesg "Error: $MAIN_CONF file is not present"
 		exit 1
	fi

	name=$1
	ip=$2
	port=$3
        defaultset=33024

        #check name length
	if [ ${#name} -gt 128 ] ; then
	       mesg "Error: ServerName should not be greater than 128 characters."
	       exit 1
	fi

        #check dup name
	duplicate="$(grep '\<'$name'\>' $MAIN_CONF)"
	if [ ${#duplicate} -ne 0 ] ; then
	       mesg "Error: Entry with given servername already exists."
	       exit 1
	fi

        #check valid ip/hostname name
	check_ip=$(valid_ip_hostname $ip);
	if [ $? != 0 ] ; then
		mesg "Error: Invalid ip address or hostname."
		exit 1
	fi

        #check valid port number
	if [ $port -eq $port 2>/dev/null ] ; then
		#valid integer
		:
	else
		#not valid integer
		mesg "Error: Invalid port number. Valid range is 1-65535."
		exit 1
	fi
	   
		
	if [ $port -lt 1 ] || [ $port -gt 65535 ] ; then
		mesg "Error: Invalid port number. Valid range is 0-65535."
		exit 1
	fi

        #write to conf file
	echo $1 $2:$3 $defaultset >> $MAIN_CONF
	RETVAL=$?
	if [ $RETVAL -ne 0 ] ; then
		mesg "Error: Could not add vpn connection profile"
		exit 1	
	fi			
	mesg "Successfully added vpn connection profile"
	exit 0
}

delete_profile() {
	#check for main conf file	
	if [ ! -f $MAIN_CONF ] ; then
		mesg "Error: $MAIN_CONF file is not present"
 		exit 0
	fi

	if [ ! -s  $MAIN_CONF ] ; then
		mesg "Error: $MAIN_CONF file is empty"
 		exit 0
	fi
	sed "/\<$ARGV\>/d" $MAIN_CONF > $TEMP_CONF
	RETVAL=$?
	if [ $RETVAL -ne 0 ] ; then
		mesg "Error: Could not delete vpn connection profile"
		exit 0	
	fi			
	cp  $TEMP_CONF $MAIN_CONF
	RETVAL=$?
	if [ $RETVAL -ne 0 ] ; then
		mesg "Error: Could not delete vpn connection profile"
		exit 0	
	fi			
	mesg "Successfully deleted vpn connection"
	exit 0	


}


# See how we were called.
case "$1" in
	cert)
    		cert $2 $3
		exit 0 
       		 ;;

	upgrade)
       		upgrade $2 
		exit 0 
	        ;;

	 authpap)
	       	authpap $2 $3 
		exit 0
       		;;


	 proxy_auth)
	       	proxy_auth $2 $3 $4
		exit 0
       		 ;;


	setting)
 		setting 
		exit 0 
        	;;

	login)
		login
		exit 0 
       		 ;;


	 logout)
		logout
		exit 0
        	;;

	 status)
		status
		exit 0
	        ;;

	 delete_profile)
		delete_profile
		exit 0
	        ;;

	 add_profile)
		add_profile $2 $3 $4
		exit 0
	        ;;
	  *)
	        echo $"Usage: $0 {login|logout|status|setting}"
	       	exit 0
esac

exit $RETVAL
