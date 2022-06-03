#!/usr/bin/env wish
proc report {} {
        global record_list
		global grp_name
        set chosen [.l curselection]
		set grp_name [lindex $record_list $chosen ]
	    	#exec  /opt/sslvpn-plus/naclient/user.sh grouplist $grp_name
		load /opt/sslvpn-plus/naclient/libsvpcli.so svpcli
		set retval [group_list $grp_name]
		#exec wish /opt/sslvpn-plus/naclient/gui/mesg return value is $retval
		if { $retval == 0 } {
                	exec wish /opt/sslvpn-plus/naclient/gui/mesg Successfully connected to SSL VPN-Plus gateway
                } else {
                #exec wish mesg Failed to SSL VPN-Plus gateway, Error code: $retval
                	error_message $retval 1
                }

		destroy .
}

proc SelectedGroup { }  {

	global  grp_name
    #wish  ./mesg "$grp_name"
	#exec  /opt/sslvpn-plus/naclient/user.sh grouplist $grp_name
	destroy .
}
proc setLabel {color} {
    global  grp_name
	set grp_name $color
	#puts "$grp_name"
}


wm protocol . WM_DELETE_WINDOW {
  #puts "Close button pressed"
exec /opt/sslvpn-plus/naclient/user.sh logout
destroy .
}
#Gui part of the TCL Tk

global  grp_name "NULL"
#wm geometry . +300+650
update
set x [expr {([winfo screenwidth .]-[winfo width . ])/2}]
set y [expr {([winfo screenheight .]-[winfo height . ])/2}]
wm geometry .  +$x+$y

wm title  .  "Groups"
scrollbar .s -command ".l yview"
listbox .l -yscroll ".s set" -selectmode single

label .label1 -justify left -text "Nothing Selected"
#button .b1 -text "OK" -command "SelectedGroup"
button .b1 -text "OK" -command "report"
bind .l <ButtonRelease-1> {setLabel [.l get active]}
message .msg -width 300 -text "\nYou are a member of groups mentioned below. Select a group for this session.\n\n" -justify left
pack .msg -pady 5
focus -force .b1

#bind .l <Double-B1-ButtonRelease> {setLabel [.l get active]}

#wm geometry . +300+650
#wm title  .  "SSL VPN-Plus Client - Group Selection"

grid .msg -row 0 -column 0
grid .l -row 1 -column 0 -sticky news
grid .s -row 1 -column 1 -sticky news
grid .b1 -row 2 -column 0 

set records_count [llength [split $argv ","]]
set record_list [split $argv ","]
#set i 0
foreach arg $record_list {
.l insert end  $arg
}
 
.l select set 0
