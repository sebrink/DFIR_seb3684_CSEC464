#!/bin/bash
#
# Forensics script for CSEC464
#
# Author: Scott Brink
#

# Colors to make each section pretty :)
red="$(tput setaf 1)"
reset="$(tput sgr0)"

# Time Information
function getTime {

    now=`date +%T)`
    timeZone=`timedatectl | grep "zone" | cut -d":" -f2)`
    up=`uptime -p`

    echo "Current Time: ${now//,},"
    echo "Time Zone: ${timeZone//,},"
    echo "Uptime: ${up//,},"

}

# OS Information
function getOS {

    numerical=`cat /etc/os-release | grep PRETTY | cut -d"=" -f2`
    typical=`cat /etc/lsb-release | grep ID | cut -d"=" -f2`
    kernel=`uname -v)`

    echo "OS: ${typical//,},"
    echo "OS Version: ${numerical//,},"
    echo "Kernel Version: ${kernel//,},"

}

# Hardware Specs
function getSpecs {

    cpu=`lscpu | grep "Model name:" | cut -d":" -f2 | awk '{$1=$1};1'`
    ram=`awk '/^MemTotal:/{print $2}' /proc/meminfo) kB`
    numHdds=`lsblk | grep disk | wc -l`
    hdds=`lsblk | grep disk | cut -d" " -f1`
    mfs=`df -h`

    echo "CPU: ${cpu//,},"
    echo "RAM: ${ram//,},"
    echo "Number of HDDs: ${numHdds//,},"
    echo "Hard Drives: ${hdds//,},"
    echo "Filesystems: "    
    echo "${mfs//,},"

}

# Hostname and Domain Info
function getHostDomain {
    
    host="host"
    domain="domain"
    
    echo "Hostname: ${host//,},"
    echo "Domain: ${domain//,},"

}

# List Users
function getUsers {
    
    ## Include UID!

    # 0-99
    systemUsers="sysUsers"
    # 100-499
    programUsers="program"
    # >1000
    addedUsers="added"
    loginHistory="history"

    echo "System Users: ${systemUsers//,},"
    echo "Program Users: ${programUsers//,},"
    echo "Normal Users: ${addedUsers//,},"
    echo "Login History: ${loginHistory//,},"

}

# Start at Boot
function getBootInfo {

    services="services"

    # include path
    programs="programs"

    echo "Services: ${services//,},"
    echo "Programs: ${programs//,},"

}

# Scheduled Tasks
function getTasks {

    tasks="tasks"

    echo "Scheduled Tasks: ${tasks//,},"

}

# Network Information
function getNetwork {

    arp="arp"
    macInt="mac"
    rtTable="route"
    ipInt="ip"
    dhcp="dhcp"
    dns="dns"
    gatewayInt="gateway"

    # Include ip, port, protocol, name
    listeningServ="listening"

    # Include remote ip, local/remote port, protocol, timestamp, name
    establishedConn="established"

    dnsCache="dnscache"

    echo "Arp Table: ${arp//,},"
    echo "Interface Mac: ${macInt//,},"
    echo "Routing Table: ${rtTable//,},"
    echo "Interface IP: ${ipInt//,},"
    echo "DHCP Server: ${dhcp//,},"
    echo "DNS Server: ${dns//,},"
    echo "Interface Gateway: ${gatewayInt//,},"
    echo "Listening Services: ${listeningServ//,},"
    echo "Established Connections: ${establishedConn//,},"
    echo "DNS Cache: ${dnsCache//,},"

}

# Network Shares
function getShares {

    networkShares="networkShares"
    printers="printers"
    wifiAccess="wifiAccess"

    echo "Network Shares: ${networkShares//,},"
    echo "Printers: ${printers//,},"
    echo "Wifi Access Profile: ${wifiAccess//,},"

}

# Process List
function getProcess {

    for pid in `ps -A -o pid`   
    do
        processName="processName"
        processId="id"
        processParent="parentId"
        processLocation="location"
        processOwner="owner"

        echo "Process Name: ${processName//,}"
        echo "Process ID: ${processId//,}"
        echo "Parent ID: ${processParent//}"
        echo "Procces Location: ${processLocation//,}"
        echo "Procces Owner: ${proccesOwner//,}"

    done
    echo ","
}

# File List
function getFiles {

    for user in `ls /home/`
    do
        echo "User: $user"
        echo "Downloads: `ls /home/$user/Downloads | tr '\n' ' '`"
        echo "Documents: `ls /home/$user/Documents | tr '\n' ' '`"
    done
    echo ","

}

# Three personal things
function getTBD {

    tbd1="tbd1"
    tbd2="tbd2"
    tbd3="tbd3"

    echo "TBD 1: ${tbd1//,},"
    echo "TBD 2: ${tbd2//,},"
    echo "TBD 3: ${tbd3//,}"

}

function main {
    getTime
    getOS
    getSpecs
    getHostDomain
    getUsers
    getBootInfo
    getTasks
    getNetwork
    getShares
    getProcess
    getFiles
    getTBD
}

main
