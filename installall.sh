#!/bin/bash
echo "Starting Installation"
#Fixes a bug that sets wrong permissions on /tmp 
chown root:root /tmp
chmod ugo+rwXt /tmp

echo "Checking for updates on base system"
#Updates base system
apt-get update && apt-get -y update

echo "configuring swap file"
#Configure swap file
dd if=/dev/zero of=/swapfile bs=2048 count=2097152
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo "/swapfile swap swap defaults 0 0" >> /etc/fstab
echo "vm.swappiness=10" >> /etc/sysctl.conf 

echo "Gathering Required Information for LAMP install"
#Get user input 
read -p "Enter FQDN for Virtual Server:   "  DOMAIN
read -p "Enter Password for Virtual Server:   "  PASSWD
 
#Sets correct time and date, edit to reflect your timezone
sudo timedatectl set-timezone America/Chicago

echo "Starting Virtualmin Installation"
#Starts Virtualmin install
#Downloads Virtualmin install script
wget http://software.virtualmin.com/gpl/scripts/install.sh

#Select the version of virtualmin you want to install.  Make sure only the version you want to install is uncommented.
#Virtualmin Minimum is everything you need unless you want a full-blown mail server with antivirus, antispam, etc.

#Installs full Virtualmin
#sh ./install.sh -f -v

#Installs Virtualmin Minimum (default)
sh ./install.sh -f -v -m
#End Virtualmin Install

echo "Creating virtual server"
#Start virtual server install
DOMAINUSER=`echo "$DOMAIN" | cut -d'.' -f 1`

virtualmin create-domain --domain $DOMAIN --pass $PASSWD --desc "BMLT DEV" --unix --dir --webmin  --web --ssl --mysql --dns --mail --limits-from-plan
#End virtual domain install




