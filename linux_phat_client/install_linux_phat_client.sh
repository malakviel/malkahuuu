#!/bin/bash
###################################################################################################################
#	WORKING OF THE SCRIPT																						 #
#	This Script is used for normal installation as well as in upgrade process also,lets go one by one			 #
#																												 #
#	Normal First Installation																					 #
#	--------------------------																					 #
#	 1. Check if the old configuration is present, which is not in this case.                                    #
#	 2. Do the installation by following steps                                                                   #
#	 3. copy the untared directory in /opt/sslvpn-plus/naclient/                                                 #
#	 4. run the decode file on $DIR/naclient.cfg file which will remove the naclient.desktop from $DIR           #
#	 5. create the desktop icon and then come out.                                                               #
#                                                                                                                #
#	During upgrade                                                                                               #
#	--------------                                                                                               #
#	 1. Remove the old installation after saving its configuration file (/opt/sslvpn-plus/naclient/naclient.conf)#
#		and saving its naclient.cfg file                                                                     	 #
#	 2. and follow the Normal installation                                                                       #
#																												 #
###################################################################################################################

CLIENT=naclient
COMPANY="SSL VPN-Plus"
company="sslvpn-plus"
PRODUCT="Client"

KERNEL=`uname -r`

RELFILE="/etc/redhat-release"
RELFILE_SUSE="/etc/SuSE-release"

UPGRADE=0
TOPDIR=/opt/$company
DIR=$TOPDIR/$CLIENT
GDIR=$DIR/gui

INSTALLF=$DIR/naclient_install.conf
CLIENTF=$DIR/$CLIENT
CONF_CFG=$DIR/naclient.cfg

CONFN=$CLIENT.conf
CONFF=$DIR/$CONFN

DECODEF=$DIR/decode
PROXYUIF=$DIR/proxysetui.conf

NETD=/etc/sysconfig/network-scripts
GNOMED=/root/.gnome-desktop
KDED=/root/Desktop

GNOMEP=naclient.desktop
GNOMEN=$GNOMEP
GNOMEF=$GNOMED/$GNOMEN

KDEP=naclient.desktop
KDEN=$KDEP
KDEF=$KDED/$KDEN

PDIR="linux_phat_client"

FIREFOX_DEB_ARCH=/usr/lib/firefox/firefox
FIREFOX_RHEL_ARCH=/usr/lib64/firefox/firefox

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
#	CLID=/usr/sbin

else
	INITD=/etc/rc.d/init.d
#	CLID=/usr/local/bin
fi

if [ $RELEASE = "SUSE" ] ; then
	INITD=/etc/init.d
fi



CLID=/usr/local/bin

INITP=naclient.sh
INITN=$CLIENT
INITF=$INITD/$INITN

CLIP=login
CLIN=$CLIENT
CLIF=$CLID/$CLIN

GUIP=$GDIR/naclient.sh
GUIN=naclientg
GUIF=$CLID/$GUIN

NETP=ifcfg-vpn0
NETN=$NETP
NETF=$NETD/$NETN

DAEMONP=daemon
DAEMON=naclientd
DAEMONF=$DIR/$DAEMON

TUNDEVICE=/dev/net/tun


ARCH=`uname -m`
BINSIXTYFOUR=$DIR/sixty-four
LOGIN=login
LIBSVPCLI=libsvpcli.so
USER=user
PROXY_SET=proxy_set
NACLIENTPOLL=naclient_poll
LIBSSL=libssl.so.1.0.2
LIBCRYPTO=libcrypto.so.1.0.2

BUILTINF=built-in.conf
BUILTINCONFF=/tmp/$BUILTINF
TUNPATH=/etc/modprobe.d

REGFILEPATH=$DIR/.systemreg

LIBPHATONPORTAL=libphatonportal.so

#LOG=/tmp/naclog

####################################PRE INSTAL###################################################

if [ ! -z $UID ] ; then 
	if [ $UID -ne 0 ] ; then
		echo "Root Privileges are needed to install $COMPANY $PRODUCT"
		exit 1
	fi
fi

modprobe tun 2>/dev/null
RETVAL=$?
if [ $RETVAL -ne 0 ] ; then
        echo -e "install tun /bin/true\n" >$BUILTINCONFF
        cp $BUILTINCONFF $TUNPATH/$BUILTINF
fi



if [ ! -c $TUNDEVICE ] ; then
	echo "No TUN Device !!!"
	echo "TUN device is needed to run SSL VPN-Plus Client !!!"
	exit 1 
#else
	#chmod 0777 $TUNDEVICE
fi


if  [ ! -d  $PDIR ] ; then
      echo "Error: $PDIR directory is not present"
      exit 1
fi

#Checking for firefox NSS libs
echo -n "Checking for NSS Libs: "
if [ -a $FIREFOX_DEB_ARCH -o -a $FIREFOX_RHEL_ARCH ] ; then
	echo "NSS libs available"
else
	echo "NSS library is not available .. exiting"
	exit 1
fi


#check if client running ,if yes then stop it
RETVAL=`pstree | grep naclientd | wc -l`
RETVAL1=`pstree | grep naclient_poll | wc -l`
if [ $RETVAL -ne 0 -a $RETVAL -ne 0 ] ; then
	echo "Warning $COMPANY $PRODUCT is running"	
	echo "Installation will stop $COMPANY $PRODUCT"
	echo -e "Do you want to continue (y/n): \c"
	read choice
	if [ $choice = "y" -o $choice = "Y" ] ; then
		echo " 	"
		if [ $RELEASE = "DEBIAN" ] ; then
			$INITD/$CLIENT stop 2> /dev/null
		else
			service $CLIENT stop 2> /dev/null
		fi 
		RETVAL=$?
		if [ $RETVAL -ne 0 ] ; then
			ifconfig tap0 down 2> /dev/null
			RETVAL=$?
			if [ $RETVAL -ne 0 ] ; then
				echo "Error: Unable to stop $COMPANY $PRODUCT"
				exit 1		
			fi
		fi
		# if daemon is running then kill it before moving ahead with installation
                killall -9 $DAEMON >/dev/null 2>&1
                killall -9 $NACLIENTPOLL >/dev/null 2>&1

	else	
		echo " "
	 	exit 1	
	fi
fi


################################## Net-Tools Installation ############################################

if [ $RELEASE = "DEBIAN" ] ; then
	echo -n "Net-Tools is being installed ... "
	apt-get -y install net-tools > /dev/null
	if [ $? -eq 0 ] ; then
		echo  "Done"
        fi
elif [ $RELEASE = "SUSE" ] ; then
	echo  "Net-Tools is being installed ... "
	YaST2 -i net-tools > /dev/null
	if [ $? -eq 0 ] ; then
	echo "Done"
	fi
else
	echo -n "Net-Tools is being installed ... "
	yum -y install net-tools > /dev/null
	if [ $? -eq 0 ] ; then
		echo "Done"
	fi
fi


################################## TCL TK Installation ############################################

if [ $RELEASE = "DEBIAN" ] ; then
	echo -n "TCL is being installed ... "
	apt-get -y install tcl > /dev/null
	if [ $? -eq 0 ] ; then
		echo  "Done"
	fi
	echo -n "TK is being installed ... "
	apt-get -y install tk > /dev/null
	if [ $? -eq 0 ] ; then
		echo "Done"
	fi
	echo -n "libtk-img is being installed ... "
        apt-get -y install libtk-img > /dev/null
        if [ $? -eq 0 ] ; then
                echo "Done"
        fi
elif [ $RELEASE = "SUSE" ] ; then
	echo  "TCL is being installed ... "
	YaST -i tcl > /dev/null
	if [ $? -eq 0 ] ; then
	echo "Done"
	fi
	echo  "TK is being installed ... "
	YaST -i tk > /dev/null
	if [ $? -eq 0 ] ; then
	echo "Done"
	fi
	echo  "tkimg is being installed ... "
        yast -i tkimg > /dev/null
        if [ $? -eq 0 ] ; then
        echo "Done"
        fi
else
	echo -n "TCL is being installed ... "
	yum -y install tcl > /dev/null
	if [ $? -eq 0 ] ; then
		echo "Done"
	fi
	echo -n "TK is being installed ... "
	yum -y install tk > /dev/null
	if [ $? -eq 0 ] ; then
		echo "Done"
	fi
	echo -n "tkimg is being installed ... "
        yum -y install tkimg > /dev/null
        if [ $? -eq 0 ] ; then
                echo "Done"
        fi
fi

###################################################################################################

#########################OLD BUILD---backword compatibility######################################################
#if config file present and old build installed then copy into /tmp
if [ -f /opt/neoaccel/naclient/naclient.conf ] ; then 
	cp -f /opt/neoaccel/naclient/naclient.conf /tmp/$CONFN  > /dev/null
	RETVAL=$?
	if [ $RETVAL -ne 0 ] ; then
		echo "Error: Unable to move /opt/neoaccel/naclient/naclient.conf  file to /tmp directory"  
		exit 1		
	fi
fi	

if [ -d /opt/neoaccel/naclient ] ; then
	rm -rf /opt/neoaccel/naclient/naclient
	RETVAL=$?
	if [ $RETVAL -ne 0 ] ; then 
		echo "Error: Could not remove /opt/neoaccel/naclient/naclient directory" 
		echo "Please check /opt/neoaccel/naclient/naclient directory permission" 
		exit 1 
	fi
	UPGRADE=1
fi

#############################################TAKE BACKUP#####################################################
#move the /opt/sslvpn-plus/naclient/naclient.conf new build
if [ -f $CONFF ] ; then 
	cp -f $CONFF	/tmp/$CONFN  > /dev/null
	RETVAL=$?
	if [ $RETVAL -ne 0 ] ; then
		echo "Error: Unable to move $CONFF file to /tmp  directory "
		echo "Warning if you will continue ,your pervious configuration of $COMPANY Gateway will lost" 
		echo -e "Do you want to continue (y/n): \c"
		read choice
		if [ $choice = "y" -o $choice = "Y" ] ; then
			echo " "
		else
			echo "  "
			exit 1 
		fi
	fi

fi

#Copy the cfg file 
if [ -f $GNOMEF ] ; then 
	cp -f  $GNOMEF /tmp/ > /dev/null
	RETVAL=$?
	if [ $RETVAL -ne 0 ] ; then
		echo "Error: Unable to move $CONFF file to /tmp directory" 
		exit 1		
	fi
fi

if [ -f $KDEF ] ; then
	cp -f $KDEF /tmp/ > /dev/null
	RETVAL=$?
	if [ $RETVAL -ne 0 ] ; then
		echo "Error: Unable to move $CONFF file to /tmp directory" 
		exit 1		
	fi
fi

if [ -f $REGFILEPATH ] ; then
        cp -f  $REGFILEPATH /tmp/ > /dev/null
        RETVAL=$?
        if [ $RETVAL -ne 0 ] ; then
                echo "Error: Unable to move $REGFILEPATH file to /tmp directory" 
                exit 1
        fi
fi



#####################    REMOVE OLD DIRECCTORIES   ###################################
#if /opt/sslvpn-plus/neaclient/ directory existed means we want to upgrade.
#if [ -d $DIR  ] ; then
#	rm -rf $DIR   > /dev/null
#	RETVAL=$?
#	if [ $RETVAL -ne 0 ] ; then 
#		echo "Error: Could not remove $DIR directory" 
#		echo "Please check $DIR directory permission" 
#		exit 1 
#	fi
#	UPGRADE=1
#fi

#remove the /opt/sslvpn-plus/naclient  file if present
#if [ -f $DIR  ] ; then
#	rm -f $DIR  > /dev/null
#	RETVAL=$?
#	if [ $RETVAL -ne 0 ] ; then 
#		echo "Error: Could not remove $DIR file" 
#		echo "Please check $DIR file permission" 
#		exit 1
#	fi
#fi 

#remove /etc/init.d/nacliet file
if [ -f $INITF ] ; then 
	rm  -f $INITF  > /dev/null
	RETVAL=$?
	if [ $RETVAL -ne 0 ] ; then 
		echo "Error while deleting $INITF file" 
		echo "Please check $INITF file permission"
		exit 1
	fi
fi
#remove cli file /usr/local/bin/naclient
if [ -f $CLIF ] ; then 
	rm  -f $CLIF  > /dev/null
	RETVAL=$?
	if [ $RETVAL -ne 0 ] ; then 
		echo "Error while deleting $CLIF file"  
		echo "Please check $CLIF file permission" 
		exit 1
	fi
fi

#remove GNOME file /root/.gnome_desktop/naclient.desktop
if [ -f  $GNOMEF ] ; then 
	rm -f $GNOMEF	 > /dev/null
	RETVAL=$?
	if [ $RETVAL -ne 0 ] ; then 
		echo "Error :Could not delete  $GNOMEF file" 
		echo "Please check permission of $GNOMEF file" 
		exit 1
	fi
fi

#remove KDE file /root/Desktop/naclient.desktop
if [ -f  $KDEF	] ; then 
	rm -f $KDEF	 > /dev/null
	RETVAL=$?
	if [ $RETVAL -ne 0 ] ; then 
		echo "Error: Could not delete $KDEF file"  
		echo "Please check permission of $KDEF file"
		exit 1
	fi	
fi

############################### direcory creation and copying ####################################

if  [ ! -d  $TOPDIR ] ; then 
	mkdir -p $TOPDIR > /dev/null
	RETVAL=$?
	if [ $RETVAL -ne 0 ] ; then 
		echo "Error: while creating $TOPDIR directory " 
		exit 1 
	fi
fi

#copy the directory to /opt/sslvpn-plus/naclient/
cp -rf $PDIR $DIR > /dev/null
RETVAL=$?
if [ $RETVAL -ne 0 ] ; then 
	echo "Error while moving $PDIR directory to $DIR directory" 
	echo "Please check $PDIR and $TOPDIR directory permission"  
	exit 1 
fi


if [ ! -f $DECODEF ] ; then 
	echo "Error: $DECODEF file is not present" 
	rm -rf $DIR	 > /dev/null
	exit 1 
fi

#goto /opt/sslvpn-plus/naclient/
cd $DIR  > /dev/null
RETVAL=$?
if [ $RETVAL -ne 0 ] ; then 
	echo "Error: Unable to change directory to $DIR directory" 
	echo "Please check $DIR directory permission" 
	rm -rf $DIR > /dev/null
	exit 1 
fi


#bring /tmp/naclient.conf if any to /opt/sslvpn-plus/naclient/
if [ -f /tmp/$CONFN ]  ; then 
	mv -f /tmp/$CONFN $DIR/.  > /dev/null
	RETVAL=$?
	if [ $RETVAL -ne 0 ] ; then 
		echo "Error while /tmp/$CONFN file to $DIR directory" 
		echo "Please check $DIR directory permission" 
		rm -rf $DIR
		exit 1
	fi
fi

#If client.cfg is not present then remove all and exit
if [ ! -f $CONF_CFG ] ; then 
	echo "Error: $CONF_CFG file is not present" 
	rm -rf $DIR	 > /dev/null
	exit 1 
fi


#decode the file and delete if not present


$DECODEF $CONFN > /dev/null
if [ ! -f $CONFF ] ; then 
	echo "Error: unable to create $CONFF file" 
	echo "Please check $DIR directory permission" 
	rm -rf $DIR	 > /dev/null
	exit 1 
fi

rm -f $DECODEF > /dev/null
RETVAL=$?
if [ $RETVAL -ne 0 ] ; then 
	echo "Error: $DECODEF file is not present"
	rm -rf $DIR	 > /dev/null
	exit 1 
fi


rm -f $CONF_CFG > /dev/null
RETVAL=$?
if [ $RETVAL -ne 0 ] ; then 
	echo "Error: $CONF_CFG file is not present" 
	rm -rf $DIR	 > /dev/null
	exit 1 
fi

mv -f $DIR/$INITP  $INITF > /dev/null
RETVAL=$?
if [ $RETVAL -ne 0 ] ; then
	echo "Error while copying $DIR/$INITP file to $INITD directory" 
	echo "Please check $INITD directory permission"
	rm -rf $DIR	 > /dev/null
	exit 1
fi

mv -f $DIR/$CLIP  $CLIF > /dev/null
RETVAL=$?
if [ $RETVAL -ne 0 ] ; then 
      echo "Error while copying $CLIF file to $CLID directory" 
      echo "Please check $CLID directory permission " 
      rm -rf $DIR	 > /dev/null
      rm -f $INITF > /dev/null
      exit 1
fi

touch $PROXYUIF > /dev/null
chmod 666 $PROXYUIF > /dev/null

cp -f $GUIP  $GUIF > /dev/null
RETVAL=$?
if [ $RETVAL -ne 0 ] ; then 
	echo "Error while copying $GUIP file to $CLID directory"  
	echo "Please check $CLID directory permission "
	rm -rf $DIR	 > /dev/null
	rm -f $INITF > /dev/null
	rm -f $CLIF	 > /dev/null
	exit 1
fi

mv  -f $DIR/$DAEMONP $DAEMONF > /dev/null
RETVAL=$?
if [ $RETVAL -ne 0 ] ; then
      echo "Error while copying $DIR/$DAEMONP to $DIR directory"
      echo "Please check $DIR directory permission"
      rm -rf $DIR	 > /dev/null
      rm -f $INITF > /dev/null
      rm -f $CLIF > /dev/null
      rm -f $GUIF	 > /dev/null
      exit 1
fi
if [ $ARCH = "x86_64" ] ; then
     if  [ ! -d  $BINSIXTYFOUR ] ; then
                echo "Error: $BINSIXTYFOUR directory is not present"
                rm -rf $DIR  > /dev/null
		rm -f $INITF > /dev/null
      		rm -f $CLIF > /dev/null
      		rm -f $GUIF        > /dev/null
                exit 1
     fi
     cp -f $BINSIXTYFOUR/$LOGIN  $CLIF >/dev/null
     RETVAL=$?
     if [ $RETVAL -ne 0 ] ; then
           echo "Error while copying $BINSIXTYFOUR/$LOGIN file to $CLID directory"
           echo "Please check $CLID directory permission "
           rm -rf $DIR      > /dev/null
           rm -f $INITF > /dev/null
           rm -f $GUIF      > /dev/null
           exit 1
     fi
     cp -f $BINSIXTYFOUR/$DAEMONP $DAEMONF > /dev/null
     RETVAL=$?
     if [ $RETVAL -ne 0 ] ; then
           echo "Error while copying $BINSIXTYFOUR/$DAEMONP to $DIR directory"
           echo "Please check $DIR directory permission"
           rm -rf $DIR      > /dev/null
           rm -f $INITF > /dev/null
           rm -f $CLIF > /dev/null
           rm -f $GUIF      > /dev/null
           exit 1
     fi
     cp -f $BINSIXTYFOUR/$LIBSVPCLI $DIR/$LIBSVPCLI >/dev/null
     RETVAL=$?
     if [ $RETVAL -ne 0 ] ; then
           echo "Error while copying $BINSIXTYFOUR/$LIBSVPCLI to $DIR/$LIBSVPCLI directory" 
           rm -rf $DIR      > /dev/null
           rm -f $INITF > /dev/null
           rm -f $CLIF > /dev/null
           rm -f $GUIF      > /dev/null
           rm -f $DAEMONF > /dev/null
           exit 1
     fi
     cp -f $BINSIXTYFOUR/$USER $DIR/$USER >/dev/null
     RETVAL=$?
     if [ $RETVAL -ne 0 ] ; then
           echo "Error while copying $DIR/$DAEMONP to $DIR directory"
           echo "Please check directory permission"
           rm -rf $DIR      > /dev/null
           rm -f $INITF > /dev/nul
           rm -f $CLIF > /dev/null
           rm -f $GUIF      > /dev/null
           rm -f $DAEMONF > /dev/null
           exit 1
     fi
     cp -f $BINSIXTYFOUR/$PROXY_SET $DIR/$PROXY_SET >/dev/null
     RETVAL=$?
     if [ $RETVAL -ne 0 ] ; then
           echo "Error while copying $DIR/$DAEMONP to $DIR directory"
           echo "Please check directory permission"
           rm -rf $DIR      > /dev/null
           rm -f $INITF > /dev/nul
           rm -f $CLIF > /dev/null
           rm -f $GUIF      > /dev/null
           rm -f $DAEMONF > /dev/null
           exit 1
     fi
     cp -f $BINSIXTYFOUR/$LOGIN $DIR/$LOGIN >/dev/null
     RETVAL=$?
     if [ $RETVAL -ne 0 ] ; then
           echo "Error while copying $BINSIXTYFOUR/$LOGIN to $DIR/$LOGIN directory"     >>$LOG
           echo "Please check directory permission"
           rm -rf $DIR      > /dev/null
           rm -f $INITF > /dev/null
           rm -f $CLIF > /dev/null
           rm -f $GUIF      > /dev/null
           rm -f $DAEMONF > /dev/null
           exit 1
     fi
     cp -f $BINSIXTYFOUR/$NACLIENTPOLL $DIR/$NACLIENTPOLL >/dev/null
     RETVAL=$?
     if [ $RETVAL -ne 0 ] ; then
           echo "Error while copying $BINSIXTYFOUR/$NACLIENTPOLL to $DIR/$NACLIENTPOLL directory"     >>$LOG
           echo "Please check directory permission"
           rm -rf $DIR      > /dev/null
           rm -f $INITF > /dev/null
           rm -f $CLIF > /dev/null
           rm -f $GUIF      > /dev/null
           rm -f $DAEMONF > /dev/null
           exit 1
     fi
     cp -f $BINSIXTYFOUR/$LIBSSL $DIR/$LIBSSL >/dev/null
     RETVAL=$?
     if [ $RETVAL -ne 0 ] ; then
           echo "Error while copying $BINSIXTYFOUR/$LIBSSL to $DIR/$LIBSSL directory"     >>$LOG
           echo "Please check directory permission"
           rm -rf $DIR      > /dev/null
           rm -f $INITF > /dev/null
           rm -f $CLIF > /dev/null
           rm -f $GUIF      > /dev/null
           rm -f $DAEMONF > /dev/null
           exit 1
     fi
     cp -f $BINSIXTYFOUR/$LIBCRYPTO $DIR/$LIBCRYPTO >/dev/null
     RETVAL=$?
     if [ $RETVAL -ne 0 ] ; then
           echo "Error while copying $BINSIXTYFOUR/$LIBCRYPTO to $DIR/$LIBCRYPTO directory"     >>$LOG
           echo "Please check directory permission"
           rm -rf $DIR      > /dev/null
           rm -f $INITF > /dev/null
           rm -f $CLIF > /dev/null
           rm -f $GUIF      > /dev/null
           rm -f $DAEMONF > /dev/null
           exit 1
     fi
#     cp -f $BINSIXTYFOUR/$LIBPHATONPORTAL $DIR/$LIBPHATONPORTAL >/dev/null
#     RETVAL=$?
#     if [ $RETVAL -ne 0 ] ; then
#	    echo "Error while copying $BINSIXTYFOUR/$LIBPHATONPORTAL to $DIR/$LIBPHATONPORTAL directory"     >>$LOG
#           echo "Please check directory permission"
#           rm -rf $DIR      > /dev/null
#           rm -f $INITF > /dev/null
#           rm -f $CLIF > /dev/null
#           rm -f $GUIF      > /dev/null
#           rm -f $DAEMONF > /dev/null
#           exit 1
#     fi

fi


#if /opt/sslvpn-plus/naclient/naclient.desktop
if [ -f $GDIR/$GNOMEP ] ; then 
	if [ ! -d $GNOMED ] ; then 
		mkdir -p $GNOMED  > /dev/null
		RETVAL=$?
		if [ $RETVAL -ne 0 ] ; then
			echo "Error: Could not create $GNOMED" 
			rm -rf $DIR	 > /dev/null
			rm -f $INITF > /dev/null
			rm -f $CLIF > /dev/null
			rm -f $GUIF	 > /dev/null
			rm -f $DAEMONF > /dev/null
			exit 1	
		fi
	fi

	if [ $UPGRADE -eq 1 ] ; then
		if [ -f /tmp/$GNOMEP  ] ; then 
			cp -pf /tmp/$GNOMEP	$GNOMEF > /dev/null
		else
			echo "The icon file not present in earlier setting" 
		fi
	else
		cp -pf $GDIR/$GNOMEP	  $GNOMEF > /dev/null
	fi
	RETVAL=$?
	if [ $RETVAL -ne 0 ] ; then 
		echo "Error while copying $GDIR/$GNOMEP  file to $GNOMED directory" 
		echo "Please check $GNOMED directory permission " 
		rm -rf $DIR	 > /dev/null
		rm -f $INITF > /dev/null
		rm -f $CLIF > /dev/null
		rm -f $GUIF	 > /dev/null
		rm -f $DAEMONF > /dev/null
		exit 1
	fi

	if [ ! -d $KDED ] ; then 
		mkdir -p $KDED  > /dev/null
		RETVAL=$?
		if [ $RETVAL -ne 0 ] ; then
			echo "Error: Could not create $KDED" 
			rm -rf $DIR	 > /dev/null
			rm -f $INITF > /dev/null
			rm -f $CLIF > /dev/null
			rm -f $GUIF	 > /dev/null
			rm -f $GNOMEF > /dev/null
			rm -f $DAEMONF > /dev/null
			exit 1	
		fi
		
	fi


	if [ $UPGRADE -eq 1  ] ; then
		if [ -f /tmp/.systemreg ] ; then
			cp -f /tmp/.systemreg  $REGFILEPATH > /dev/null
		fi
	fi


	if [ $UPGRADE -eq 1  ] ; then
		if [ -f /tmp/$KDEP  ] ; then 
			cp -pf /tmp/$KDEP	$KDEF > /dev/null
		else
			echo "The icon file not present in earlier setting" 
		fi
	else
		cp -pf $GDIR/$KDEP	  $KDEF > /dev/null
	fi
	RETVAL=$?
	if [ $RETVAL -ne 0 ] ; then 
		echo "Error while copying $GDIR/$KDEP  file to $KDED directory" 
		echo "Please check $KDED directory permission " 
		rm -rf $DIR	 > /dev/null
		rm -f $INITF > /dev/null
		rm -f $CLIF > /dev/null
		rm -f $GUIF	 > /dev/null
		rm -f $GNOMEF > /dev/null
		rm -f $DAEMONF > /dev/null
		exit 0
	fi

	HOMEDIRS='/home/*'
	for i in $HOMEDIRS ; do \
                #get user and owner group info for this home dir
                chuser=`getent passwd | grep $i | cut -d: -f1 | head -1 2> /dev/null`;
                if [ -z "$chuser" ]; then
                        chuser=`whoami`;
                fi
                chgroup=`id -g -n $chuser`;

		#for KDE Desktop
		if [ -d $i/Desktop ] ; then 	
			if [ $UPGRADE -eq 1 ] ; then
				if [ -f /tmp/$KDEP  ] ; then 
					cp -pf /tmp/$KDEP $i/Desktop/. > /dev/null
                                        chown $chuser:$chgroup $i/Desktop/$KDEP 2> /dev/null
				else
					echo "The icon file not present in earlier setting for $i" 
				fi
			else
				cp -f $GDIR/$KDEP $i/Desktop/.  2> /dev/null
                                chown $chuser:$chgroup $i/Desktop/$KDEP 2> /dev/null 
			fi	
		fi

		#for GNOME desktop
		if [ -d $i/.gnome-desktop ] ; then 	
			if [ $UPGRADE -eq 1  ] ; then
				if [ -f /tmp/$GNOMEP  ] ; then 
					cp -pf /tmp/$GNOMEP $i/.gnome-desktop/. > /dev/null
                                        chown $chuser:$chgroup $i/.gnome-desktop/$GNOMEP 2> /dev/null
				else
					echo "The icon file not present in earlier setting for $i" 
				fi
			else
				cp -f $GDIR/$GNOMEP $i/.gnome-desktop/. 2> /dev/null
                                chown $chuser:$chgroup $i/.gnome-desktop/$GNOMEP 2> /dev/null
			fi
		fi	
	done

fi

if [ $RELEASE = "DEBIAN" ] ; then
       #  echo "before update" 
       #  chmod +x $INITD/$CLIENT
       update-rc.d naclient start 99 2 3 4 5 . stop 99 0 1 6 . 2> /dev/null
 #	update-rc.d naclient defaults > /dev/null
      #   echo "after update"
      #  chmod +x $INITD/$CLIENT        
else
	chkconfig --add $CLIENT > /dev/null
	`chkconfig  $CLIENT on` > /dev/null
fi	

set `date +%S`
SECOND=`expr $1 \* 1 ` 
echo "SECOND=$SECOND" >> $INSTALLF

set `date +%M`
MINUTE=`expr $1 \* 1 ` 
echo "MINUTE=$MINUTE" >> $INSTALLF

set `date +%H`
HOUR=`expr $1 \* 1 ` 
echo "HOUR=$HOUR" >> $INSTALLF

set `date +%d`
DATE=`expr $1 \* 1 ` 
echo "DATE=$DATE"  >> $INSTALLF

set `date +%m`
MONTH=`expr $1 \* 1 ` 
echo "MONTH=$MONTH" >> $INSTALLF

set `date +%y`
YEAR=`expr $1 \* 1 ` 
echo "YEAR=$YEAR" >> $INSTALLF

chmod 777 $CONFF > /dev/null
#VAL=`cat $CONFF | cut -d ' ' -f 3`
#PROFILEVAL=$(expr $(($VAL & 8)))
#	if [ $PROFILEVAL -eq 8 ] ; then
#		PROFILE=`cat $CONFF | cut -d ' ' -f 1`
#                echo "This installation package sets SSL VPN-Plus client in service mode"
#		echo "Setting up service mode for the SSL VPN-Plus client..."
#		echo -e  "Enter user name:\c"
#		read username
#		echo -e "Enter password:\c\n"
#		read -s  password

#		if [ -z "$username" ] ; then
#		user=" "
#		else
#		user=$username
#		fi
#		if [ -z "$password" ] ; then
#		pass=" "
#		else
#		pass=$password
#		fi
#		COMMAND_STR="COMMAND=\"\$DIR/login login -profile $PROFILE -user $user -password $pass \" "
#                        echo $COMMAND_STR >>/opt/sslvpn-plus/naclient/macro.sh

#	fi




#if [ $KERNEL = "2.4.27" -o $KERNEL = "2.4.27-2-386" ] ; then
if [ $RELEASE = "DEBIAN" ] ; then
	$INITD/$CLIENT start
else
	service $CLIENT start > /dev/null
fi 

echo " "	
if [ $UPGRADE -eq 0 ] ; then 
	echo "$COMPANY $PRODUCT is successfully installed" 
else
	echo "$COMPANY $PRODUCT is successfully upgraded" 
fi
