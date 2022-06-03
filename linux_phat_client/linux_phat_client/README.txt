		SSL VPN-Plus Linux Client Manual

Contents.
1. System Requirements
2. How to use Linux Client 
3. Uninstallation Procedure


1. System Requirements:
	Linux System having install any one of following kernel 
	1.1 Redhat 9.0  and kernel version 2.4.20-8
	1.2 Knnopix 3.6  and kernel version 2.4.27
	1.3 Debian kernel version 2.4.27-2-386
	1.4 Redhat Enterprise ES V3.0 and kernel version 2.4.21-4.EL
	1.5 Redhat Enterprise ES V3.0(update 1) and kernel version 2.4.21-9.EL
	1.6 Redhat Enterprise ES V3.0(update 2) and kernel version 2.4.21-15.EL
	1.7 Redhat Enterprise ES V3.0(update 3) and kernel version 2.4.21-20.EL
	1.8 Redhat Enterprise ES V3.0(update 4) and kernel version 2.4.21-27.EL
	1.9 Redhat Enterprise ES V3.0(update 5) and kernel version 2.4.21-32.EL
	1.10 Redhat Enterprise ES V3.0(update 6) and kernel version 2.4.21-37.EL

2. How to use Linux Client:

	2.1 How to connect to SSL VPN-Plus gateway
	  	Use following command to connect SSL VPN-Plus gateway: 
			$ naclient login

	2.2 How to disconnect from SSL VPN-Plus gateway
		Use following command to disconnect from SSL VPN-Plus gateway: 
			$ naclient logout

	2.3 How to check statistics of SSL VPN-Plus Connection  to gateway
		To check statistics of Linux Client use following command
			$ naclient status

	2.4 How to check Private Network Setting of Gateway
		To check setting private network setting to which your connected run command 
			$ naclient setting

	2.5 How to run client gui in X-window using terminal 
		To run client gui from X-window terminal run command 
			$ naclientg 



3. Uninstallation Procedure: 
	To uninstall linux client run following command from any directory :
		$ sh  /opt/sslvpn-plus/naclient/uninstall.sh


Note: All commands of can be used excuted from any directory.
