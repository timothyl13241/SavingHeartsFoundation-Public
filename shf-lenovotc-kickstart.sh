#!/bin/bash
#
# File: shf-kickstart.sh
#
# Purpose: Kickstart SHF thin clients
#
# Author: Timothy Le
#         <timothy.le@savingheartsfoundation.com>
#

echo "Installing updates..."
apt-get -y update

echo "Upgrading packages..."
apt-get -y upgrade

echo "Install management tools and necessary applications..."
apt-get -y install ntpdate remmina remmina-plugin-rdp remmina-plugin-secret remmina-plugin-spice

echo "Initial time sync..."
timedatectl set-timezone America/Los_Angeles
ntpdate -b pool.ntp.org

echo "Fix boot for Lenovo IdeaPad 100s..."
apt-get -y install grub-efi-ia32-bin
efibootmgr -o 0000,0001,2001,2002,2003
update-grub
grub-install /dev/mmcblk1

echo "Disable sleep..."
echo "AllowSuspend=no" >> /etc/systemd/sleep.conf
echo "AllowHibernation=no" >> /etc/systemd/sleep.conf
echo "AllowSuspendThenHibernate=no" >> /etc/systemd/sleep.conf
echo "AllowHybridSleep=no" >> /etc/systemd/sleep.conf

echo "Add WiFi network..."
read -p "Enter AP1764 password: " pass
nmcli device wifi connect "AP1764" password "$pass"

echo "Configuration complete."
echo "Reboot? Press enter to drop to terminal [r]"
read SD

if [ `echo $SD | egrep 'r'` ]; then
	rm shf-lenovotc-kickstart.sh > /dev/null 2>&1
	reboot now
else
	echo "Remove script files manually."
fi

exit 0
