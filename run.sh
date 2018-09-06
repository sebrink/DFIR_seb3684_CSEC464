#/bin/bash
#
# Script to automate running forensics.sh over ssh
#
# Author: Scott Brink
#

creds=" "
userArr=()
passArr=()
ipArr=()

echo "Hit enter with no credentials to start! Format must be correct!"

# Gather info
while [ "$creds" != "" ]
do    
    read -p 'username/password/ip ' creds

    user=`echo $creds | cut -d"/" -f1`
    userArr+=("$user")

    pass=`echo $creds | cut -d"/" -f2`
    passArr+=("$pass")

    ip=`echo $creds | cut -d"/" -f3`
    ipArr+=("$ip")

done

amount=$((${#userArr[@]}-1))

for (( i=0; i<${amount}; i++ ));
do
    sshpass -p ${passArr[$i]} ssh ${userArr[$i]}@${ipArr[$i]} "bash -s" < ~/Documents/Scripts/lab01/forensics.sh | tee ${userArr[$i]}-file$i.csv
done
