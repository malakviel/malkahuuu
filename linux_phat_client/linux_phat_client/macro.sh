KERNEL=`uname -r`
TOPDIR=/opt/sslvpn-plus
CLIENT=naclient
DIR=$TOPDIR/$CLIENT
GDIR=$DIR/gui

POLLD=$DIR/naclient_poll
CLIENT_MODULE=$CLIENT-$KERNEL
CLIENT_MODULE_O=$CLIENT-$KERNEL.o
CLIENTD=/opt/sslvpn-plus/naclient/naclientd

INIT_SCRIPTD=/etc/rc.d/init.d
NETWORK_SCRIPTD=/etc/sysconfig/network-scripts
KDE_DESKTOP=/root/Desktop
GNOME_DESKTOP=/root/.gnome-desktop
CLID=/usr/local/bin
RELFILE="/etc/redhat-release"

if  [ ! -f  $RELFILE ] ; then
    RELEASE="DEBIAN"
else
    RELEASE="REDHAT"
fi

if [ $RELEASE = "DEBIAN" ] ; then
	INITD=/etc/init.d		
	INIT_SCRIPTD=/etc/init.d
#	CLID=/usr/sbin
fi
GUIF=$CLID/naclientg

CHAR_DEV=$CLIENT
LOGF=$DIR/naclient.log

INSTALL_CONF=$DIR/naclient_install.conf
ERROR_CODEF=$DIR/error_code
MAIN_CONF=$DIR/naclient.conf	
TEMP_CONF=/tmp/naclient.conf	
STATUS_CONF=$DIR/status.conf
PRIV_NETWORK_CONF=$DIR/priv_network.conf
GATEWAY_CONF=/tmp/gateway.conf
LOGIN_CONF=$DIR/login.conf

USERF=$DIR/user
PARSERF=$DIR/parser
USERF_CLI=$DIR/user.sh 
USERF_LOGIN=$DIR/login 


MAIN_GF=$GDIR/naclient.sh
GUI_GF=$GDIR/gui
USER_GF=$GDIR/user.sh
SETTING_GF=$GDIR/advsettings
STATUS_GF=$GDIR/status
AUTH_GF=$GDIR/auth
UPGRADE_GF=$GDIR/upgrade
CERT_KEY_GF=$GDIR/cert_key
ERROR_GF=$GDIR/mesg





