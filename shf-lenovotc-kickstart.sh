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
apt-get -y install ntpdate remmina remmina-plugin-rdp remmina-plugin-secret remmina-plugin-spice traceroute
wget -O - "https://nitpro.servicedesk.atera.com/api/utils/AgentInstallScript/Linux/0013z00002fL1rhAAC?customerId=7" | bash
curl https://raw.githubusercontent.com/virtualhere/script/main/install_server | sh

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

echo "Configure Remmina profile..."
read -p "Enter terminal server IP: " rip
mkdir /home/ubuntu/.remmina
echo "[remmina]" > /home/ubuntu/.remmina/SHF.remmina
echo "disableclipboard=1" >> /home/ubuntu/.remmina/SHF.remmina
echo "ssh_auth=0" >> /home/ubuntu/.remmina/SHF.remmina
echo "name=SHFTerminal" >> /home/ubuntu/.remmina/SHF.remmina
echo "protocol=RDP" >> /home/ubuntu/.remmina/SHF.remmina
echo "username=SHF_User" >> /home/ubuntu/.remmina/SHF.remmina
echo "server=$rip" >> /home/ubuntu/.remmina/SHF.remmina
echo "quality=2" >> /home/ubuntu/.remmina/SHF.remmina
echo "colordepth=32" >> /home/ubuntu/.remmina/SHF.remmina
echo "window_maximize=1" >> /home/ubuntu/.remmina/SHF.remmina
echo "viewmode=4" >> /home/ubuntu/.remmina/SHF.remmina
echo "password=" >> /home/ubuntu/.remmina/SHF.remmina
echo "domain=SHF" >> /home/ubuntu/.remmina/SHF.remmina
echo "scale=1" >> /home/ubuntu/.remmina/SHF.remmina
echo "resolution_mode=1" >> /home/ubuntu/.remmina/SHF.remmina

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
