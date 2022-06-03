CLIENT=naclient
DIR=/opt/sslvpn-plus/naclient
COMP_DIR=/opt/sslvpn-plus

#N_VPN_CFGF=ifcfg-vpn0 	
NIT_SCRIPTD=/etc/rc.d/init.d
NETWORK_SCRIPTD=/etc/sysconfig/network-scripts
KDE_DESKTOP=/root/Desktop
GNOME_DESKTOP=/root/.gnome-desktop

CLID=/usr/local/bin
DAEMON=/usr/sbin/naclientd
KERNEL=`uname -r`
INIT_SCRIPTD=/etc/rc.d/init.d
RELFILE="/etc/redhat-release"
RELFILE_SUSE="/etc/SuSE-release"

if  [ ! -f  $RELFILE ] ; then
	RELEASE="DEBIAN"
else
	RELEASE="REDHAT"
fi

if [ -f $RELFILE_SUSE ] ; then
	RELEASE="SUSE"
fi



if [ $RELEASE = "DEBIAN" ] ; then
	INITD=/etc/init.d		
	INIT_SCRIPTD=/etc/init.d
#	CLID=/usr/sbin
else
	INITD=/etc/rc.d/init.d
#	CLID=/usr/local/bin
fi

#CLID=/usr/local/bin

GUIF=$CLID/naclientg

if [ -d $DIR  ] ; then
	echo -e "Do you want to uninstall SSL VPN-Plus Client (y/n): \c"
	read choice
	if [ $choice = "y" -o $choice = "Y" ] ; then
		echo "  "
		RETVAL=`pstree | grep naclient | wc -l`
		if [ $RETVAL -ne 0 ] ; then
			echo "Warning! $CLIENT service is running "
			echo "Uninstallation will stop SSL VPN-Plus Client"
			echo -e "Do you want to continue (y/n): \c"
			read choice
			if [ $choice = "y" -o $choice = "Y" ] ; then
				if [ $RELEASE = "DEBIAN" ] ; then
				#if [ $KERNEL = "2.4.27" -o $KERNEL = "2.4.27-2-386" ] ; then
					$INITD/$CLIENT stop
				else
					service $CLIENT stop > /dev/null
				fi 
				RETVAL=$?
				if [ $RETVAL -ne 0 ] ; then 
					echo "Error: Unable to stop SSL VPN-Plus Client"
					exit 0
				fi
			else
				echo "  "
				exit 0
			fi
		fi
	else
		echo " "
		exit 
	fi	
fi

#if [ `uname -r` = "2.4.27" -o `uname -r` = "2.4.27-2-386"   ] ; then 
if [ $RELEASE = "DEBIAN" ] ; then
	update-rc.d -f $CLIENT remove > /dev/null
	#if [ -f /etc/skel/Desktop/naclient.desktop ] ; then 	
	#	mv -f /etc/skel/Desktop/naclient.desktop  2> /dev/null
	#fi
else	
	chkconfig --del $CLIENT > /dev/null
	
fi	


if [ -f  $INIT_SCRIPTD/$CLIENT ] ; then 
	rm -f  $INIT_SCRIPTD/$CLIENT > /dev/null
	RETVAL=$?
	if [ $RETVAL -ne 0 ] ; then 
		echo "Error while removing $INIT_SCRIPTD/$CLIENT file"
		echo "Please check $INIT_SCRIPTD/$CLIENT file permissions "
		exit 0
	fi
fi

if [ -f  $CLID/$CLIENT  ] ; then 
	rm -f  $CLID/$CLIENT > /dev/null
	RETVAL=$?
	if [ $RETVAL -ne 0 ] ; then 
		echo "Error while removing $CLID/$CLIENT file"
		echo "Please check $CLID/$CLIENT file permissions "
		exit 0
	fi
fi

if [ -f  $GUIF  ] ; then 
	rm -f  $GUIF > /dev/null
	RETVAL=$?
	if [ $RETVAL -ne 0 ] ; then 
		echo "Error while removing $GUIF file"
		echo "Please check $GUIF file permissions "
		exit 0
	fi
fi


if [ -f  $DAEMON  ] ; then 
	rm -f  $DAEMON > /dev/null
	RETVAL=$?
	if [ $RETVAL -ne 0 ] ; then 
		echo "Error while removing $DAEMON file"
		echo "Please check $DAEMON file permissions "
		exit 0
	fi
fi

#if [ `uname -r` = "2.4.27" -o `uname -r` = "2.4.27-2-386"   ] ; then 
#	sed '/vpn0/d' /etc/network/interfaces	> /tmp/interfaces.$$
#	mv /tmp/interfaces.$$ /etc/network/interfaces	 
#else
#	if [ -f $NETWORK_SCRIPTD/$N_VPN_CFGF ] ; then	
#		rm  -f $NETWORK_SCRIPTD/$N_VPN_CFGF  > /dev/null	
#		RETVAL=$?
#		if [ $RETVAL -ne 0 ] ; then 
#			echo "Error while removing $NETWORK_SCRIPTD/$N_VPN_CFGF file"
#			echo "Please check $NETWORK_SCRIPTD/$N_VPN_CFGF file permissions"
#			exit 0 
#		fi 
#	fi
#fi	

if [ -f  $KDE_DESKTOP/$CLIENT.desktop ] ; then
	rm -f  $KDE_DESKTOP/$CLIENT.desktop	  > /dev/null
	RETVAL=$?
	if [ $RETVAL -ne 0 ] ; then 
		echo "Error while removing $KDE_DESKTOP/$CLIENT.desktop file "
		echo "Please check $KDE_DESKTOP/$CLIENT.desktop file directory permissions "
		exit 0
	fi
fi
 
if [ -f $GNOME_DESKTOP/$CLIENT.desktop ] ; then
	rm -f $GNOME_DESKTOP/$CLIENT.desktop	  > /dev/null
	RETVAL=$?
	if [ $RETVAL -ne 0 ] ; then 
		echo "Error while removing $GNOME_DESKTOP/$CLIENT.desktop file "
		echo "Please check $GNOME_DESKTOP/$CLIENT.desktop file directory permissions "
		exit 0
	fi
fi 

rm -rf  $DIR > /dev/null
RETVAL=$?
if [ $RETVAL -ne 0 ] ; then 
	echo "Error while removing $DIR directory "
	echo "Please check $DIR directory permissions"
	exit 0 
fi

rm -rf  $COMP_DIR > /dev/null
RETVAL=$?
if [ $RETVAL -ne 0 ] ; then 
	echo "Error while removing $COMP_DIR directory "
	echo "Please check $COMP_DIR directory permissions"
	exit 0 
fi



HOMEDIRS='/home/*'
for i in $HOMEDIRS ; do \
	if [ -d $i/Desktop ] ; then 	
		if [ -f $i/Desktop/naclient.desktop  ] ;  then 
			rm -f $GDIR/$KDEP $i/Desktop/naclient.desktop  2> /dev/null
		fi		
	fi	
	if [ -d $i/.gnome-desktop ] ; then 	
		if [ -f $i/.gnome-desktop/naclient.desktop ] ; then
			rm  -f $i/.gnome-desktop/naclient.desktop 2> /dev/null
		fi		
	fi	
done





echo "Successfully uninstalled SSL VPN-Plus Client"
