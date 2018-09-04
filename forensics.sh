#!/bin/bash
#
# Forensics script for CSEC464
#
# Author: Scott Brink
#

# Time Information
function getTime {

    echo "----------Time Info----------"

    now=`date +%T`
    timeZone=`timedatectl | grep "zone" | cut -d":" -f2`
    up=`uptime -p`

    echo "Current Time: ${now//,},"
    echo "Time Zone: ${timeZone//,},"
    echo "Uptime: ${up//,},"

    echo ""

}

# OS Information
function getOS {

    echo "----------OS Information----------"

    numerical=`cat /etc/os-release | grep PRETTY | cut -d"=" -f2`
    typical=`cat /etc/lsb-release | grep ID | cut -d"=" -f2`
    kernel=`uname -v`

    echo "OS: ${typical//,},"
    echo "OS Version: ${numerical//,},"
    echo "Kernel Version: ${kernel//,},"

    echo ""

}

# Hardware Specs
function getSpecs {

    echo "----------Hardware-----------"

    cpu=`lscpu | grep "Model name:" | cut -d":" -f2 | awk '{$1=$1};1'`
    ram=`awk '/^MemTotal:/{print $2}' /proc/meminfo`
    numHdds=`lsblk | grep disk | wc -l`
    hdds=`lsblk | grep disk | cut -d" " -f1`
    mfs=`df -h`

    echo "CPU: ${cpu//,},"
    echo "RAM: ${ram//,} kB,"
    echo "Number of HDDs: ${numHdds//,},"
    echo "Hard Drives: ${hdds//,},"
    echo "Filesystems: "    
    echo "${mfs//,},"

    echo ""
}

# Hostname and Domain Info
function getHostDomain {
    
    echo "----------Hostname and Domain----------"

    host=`hostname`
    domain=`domainname`

    echo "Hostname: ${host//,},"
    echo "Domain: ${domain//,},"

    echo ""
}

# List Users
function getUsers {
    
    echo "----------Users----------"

    ## Include UID!
    for users in `getent passwd | cut -d":" -f1` 
    do
        echo ""
        users=$users
        uid=`awk -F: -v u=$users '$1 == u {print $3}' /etc/passwd`
        gid=`awk -F: -v u=$users '$1 == u {print $4}' /etc/passwd`
        shell=`awk -F: -v u=$users '$1 == u {print $NF}' /etc/passwd`

        echo "User: ${users//,}"
        echo "UID: ${uid//,}"
        echo "GID: ${gid//,}"
        echo "Shell: ${shell//,}"
    done

    echo ""
    loginHistory=`last` 
    echo "Login History: ${loginHistory//,},"
   
    echo ""

}

# Start at Boot
function getBootInfo {

    echo "----------Boot Information----------"

    services=`initctl list`
    echo "Services: "
    echo "${services//,},"

    echo ""
}

# Scheduled Tasks
function getTasks {

    echo "----------Scheduled Tasks----------"

    tasks=$(crontab -l 2>&1)

    echo "Scheduled Tasks for `whoami`: ${tasks//,},"

    echo ""

}

# Network Information
function getNetwork {

    echo "----------Network Information----------"

    arp=`arp`
    macInt=`ifconfig -a | awk '/^[a-z]/ { iface=$1; mac=$NF; next } /inet addr:/ { print iface, mac }'`
    rtTable=`route`
    ipInt=`ip addr | awk '
    /^[0-9]+:/ { 
        sub(/:/,"",$2); iface=$2 }
    /^[[:space:]]*inet / { 
        split($2, a, "/") 
        print iface" : "a[1] }'`

    # There is probably a one liner that is going to make me look very silly
    dhcp=`journalctl | grep DHCPACK | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' | tr '\n' ' ' | awk '{print $2}'`

    dns=`cat /etc/resolv.conf | grep nameserver`
    gatewayInt=`ip route`

    # Include ip, port, protocol, name
    listeningServ="listening"

    # Include remote ip, local/remote port, protocol, timestamp, name
    establishedConn="established"

    echo "Arp Table: ${arp//,},"
    echo "Interface Mac: "
    echo "${macInt//,},"
    echo "Routing Table: "
    echo "${rtTable//,},"
    echo "Interface IP:" 
    echo "${ipInt//,},"
    echo "DHCP Server: ${dhcp//,},"
    echo "DNS Server: ${dns//,},"
    echo "Interface Gateway: "
    echo "${gatewayInt//,},"
    echo "Listening Services: ${listeningServ//,},"
    echo "Established Connections: ${establishedConn//,},"

    echo ""
}

# Printers
function getPrinters {

    echo "----------Printers----------"

    printers=`lpstat -p -d 2>&1`

    echo "Printers: "
    echo "${printers//,},"

    echo ""
}

# Process List
function getProcess {

    echo "----------Process List----------"

    for pid in `ps -A -o pid`   
    do
        processName=`ps -p $pid -o comm= 2>/dev/null`
        processId=$pid 
        processParent=`ps -o ppid= -p $pid 2>/dev/null`
        processLocation=`readlink /proc/$pid/exe 2>/dev/null`

        if [ -n "$processName" ]; then
            echo "Process Name: ${processName//,}"
        fi
        if [ -n "$processId" ]; then
            echo "Process ID: ${processId//,}"
        fi
        if [ -n "$processParent" ]; then
            echo "Parent ID: ${processParent//}"
        fi
        if [ -n "$processLocation" ]; then
            echo "Procces Location: ${processLocation//,}"
        fi
        echo ""
    done

    echo ","
    echo ""
}

# File List
function getFiles {

    echo "----------File List----------"

    for usr in `ls /home/`
    do
        echo "User: $usr"
        echo "Downloads: `ls /home/$usr/Downloads | tr '\n' ' '`"
        echo "Documents: `ls /home/$usr/Documents | tr '\n' ' '`"
    done

    echo ","
    echo ""
}

# Three personal things
function getTBD {

    echo "----------TBD----------"

    tbd1="tbd1"
    tbd2="tbd2"
    tbd3="tbd3"

    echo "TBD 1: ${tbd1//,},"
    echo "TBD 2: ${tbd2//,},"
    echo "TBD 3: ${tbd3//,}"

    echo ""
}

function main {
    echo ""
    getTime         # done
    getOS           # done
    getSpecs        # done
    getHostDomain   # done
    getUsers        # done
    getBootInfo     # done
    getTasks        # done
    getNetwork      # TODO, listening services and established connections
                    #       hard to do without root :thinking:
    getPrinters     # done
    getProcess     # done
    getFiles        # done
    getTBD          # TODO, lel idk
}

main
