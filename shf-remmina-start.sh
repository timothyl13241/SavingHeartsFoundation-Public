#!/bin/bash
#
# File: shf-remmina-start.sh
#
# Purpose: Start configured Remmina profile at startup
#
# Author: Timothy Le
#         <timothy.le@savingheartsfoundation.com>
#

file="/home/ubuntu/.remmina/SHF.remmina"
rip=$(cat "$file" | grep server | cut -d '=' -f2,4)

while ! ping -c 4 $rip > /dev/null; 
do 
echo "The VM host at $rip is not available yet."
sleep 1 
done

echo "VM host $rip is now available. Starting Remmina."
remmina -c /home/ubuntu/.remmina/SHF.remmina
