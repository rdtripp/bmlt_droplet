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

read -p "Do you want to install WordPress? (y or n) n  " INSTALLWP
if [ "$INSTALLWP" = "y" ]; then
    read -p "Enter Admin User for WordPress:   " WPADMIN
    read -p "Enter WordPress Admin User Password:   " WPADMINPASS
    read -p "Enter WordPress Default Site Name:   " WPSITENAME
    echo " Starting WordPress Install"
    #set wordpress database name
    WPDB="wp_$DOMAINUSER"
    # create database for wordpress
    echo "Creating WordPress database"
    virtualmin create-database --domain $DOMAIN --name $WPDB --type mysql

    echo "Installing WordPress"
    #Install WordPress
    virtualmin install-script --domain $DOMAIN --type wordpress --version latest --path / --db mysql $WPDB

    echo "Configuring WordPress"
    #Configure mysql database access in wp-config.php

    #/** The name of the database for WordPress */
    sed -i -- 's/database_name_here/'"$WPDB"'/g' /home/"$DOMAINUSER"/public_html/wp-config.php

    # /** MySQL database username */
    sed -i -- 's/username_here/'"$DOMAINUSER"'/g' /home/"$DOMAINUSER"/public_html/wp-config.php

    #/** MySQL database password */
    sed -i -- 's/password_here/'"$PASSWD"'/g' /home/"$DOMAINUSER"/public_html/wp-config.php

    #End WordPress Install
    echo "installing Wordress CLI"
    #Install Wordpress CLI
    apt-get update && apt-get -y install curl
    curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
    chmod +x wp-cli.phar
    sudo mv wp-cli.phar /usr/local/bin/wp
    #End Wordpress CLI install
fi

read -p "Do you want to install WordPress Multisite? (y or n) n  " INSTALLWPMS
if [ "$INSTALLWPMS" = "y" ]; then
    echo "Configuring WordPress as multisite"
    #Configure WordPress multisite
    sudo -u $DOMAINUSER wp core multisite-install --path=/home/"$DOMAINUSER"/public_html/ --url=http://"$DOMAIN"/ --title="$WPSITENAME" --admin_user=$WPADMIN --admin_password=$WPADMINPASS --admin_email=$DOMAINUSER@$DOMAIN
    wget -cO - https://raw.githubusercontent.com/rdtripp/bmlt_ubuntu_virtualmin/master/htaccess >  /home/"$DOMAINUSER"/public_html/.htaccess

    echo "Installin WordPress Plugins"
    #install WordPress Plugins
    sudo -u "$DOMAINUSER" -i -- wp --path=/home/"$DOMAINUSER"/public_html/ plugin install bmlt-wordpress-satellite-plugin --activate-network
    sudo -u "$DOMAINUSER" -i -- wp --path=/home/"$DOMAINUSER"/public_html/ plugin install bread --activate-network
    sudo -u "$DOMAINUSER" -i -- wp --path=/home/"$DOMAINUSER"/public_html/ plugin install crouton --activate-network
    sudo -u "$DOMAINUSER" -i -- wp --path=/home/"$DOMAINUSER"/public_html/ plugin install bmlt-tabbed-map --activate-network
fi

if [ "$INSTALLWPMS" != "y" ] && [ "$INSTALLWP" = "y" ]; then
    sudo -u "$DOMAINUSER" -i -- wp --path=/home/"$DOMAINUSER"/public_html/ plugin install bmlt-wordpress-satellite-plugin --activate
    sudo -u "$DOMAINUSER" -i -- wp --path=/home/"$DOMAINUSER"/public_html/ plugin install bread --activate
    sudo -u "$DOMAINUSER" -i -- wp --path=/home/"$DOMAINUSER"/public_html/ plugin install crouton --activate
    sudo -u "$DOMAINUSER" -i -- wp --path=/home/"$DOMAINUSER"/public_html/ plugin install bmlt-tabbed-map --activate
fi

read -p "Do you want to install Yap? (y or n) n" INSTALLYAP
if [ "$INSTALLYAP" = "y" ]; then
    apt install php-curl php-gd php-mbstring php-xml php-xmlrpc jq
    #Updates system to reflect new sources added by installs
    apt-get update && apt-get -y update
    echo "Starting Yap Installation"
    #set yap database name
    YAPDB="yap_$DOMAINUSER"
    echo "Creating YAP database"
    #create database for YAP
    virtualmin create-database --domain $DOMAIN --name $YAPDB --type mysql

    echo "Downloading YAP & Preparing files"
    #Get YAP
    mkdir /home/"$DOMAINUSER"/public_html/yap
    cd /home/"$DOMAINUSER"/public_html/yap
    #Download latest yap stable
    curl -s https://api.github.com/repos/bmlt-enabled/yap/releases/latest | jq -r .assets[] | jq -r .browser_download_url | wget -i -

    unzip *.zip
    chown -R "$DOMAINUSER":"$DOMAINUSER" /home/"$DOMAINUSER"/public_html/*

    echo "Configuring YAP"
    #Configure yap
    read -p "Please Enter Phone Greeting:   "  TITLE
    sed -i -- 's/$title = "";/$title = "'"$TITLE"'";/g' /home/"$DOMAINUSER"/public_html/yap/config.php

    read -p "Please enter your BMLT root server:   "  ROOTSVR
    sed -i -- 's+$bmlt_root_server = "";+$bmlt_root_server = "'$ROOTSVR'";+g' /home/"$DOMAINUSER"/public_html/yap/config.php

    read -p "Please enter your Google Maps API key:   "  GMAPAPI
    sed -i -- 's/$google_maps_api_key = "";/$google_maps_api_key = "'$GMAPAPI'";/g' /home/"$DOMAINUSER"/public_html/yap/config.php

    read -p "Please enter your twilio account sid:   "  TWILACCTSID
    sed -i -- 's/twilio_account_sid = "";/twilio_account_sid = "'$TWILACCTSID'";/g' /home/"$DOMAINUSER"/public_html/yap/config.php

    read -p "Please enter your twilio Auth Token:   " TWILAUTHTOK
    sed -i -- 's/$twilio_auth_token = "";/$twilio_auth_token = "'$TWILAUTHTOK'";/g' /home/"$DOMAINUSER"/public_html/yap/config.php

    read -p "Please BMLT root server user name:   "  BMLTUSR
    sed -i -- 's/$bmlt_username = "";/$bmlt_username = "'$BMLTUSR'";/g' /home/"$DOMAINUSER"/public_html/yap/config.php

    read -p "Please enter your BMLT root server password:   "  BMLTPASS
    sed -i -- 's/$bmlt_password = "";/$bmlt_password = "'$BMLTPASS'";/g' /home/"$DOMAINUSER"/public_html/yap/config.php

    sed -i -- 's/$mysql_hostname = "";/$mysql_hostname = "localhost";/g' /home/"$DOMAINUSER"/public_html/yap/config.php

    sed -i -- 's/$mysql_username = "";/$mysql_username = "'$DOMAINUSER'";/g' /home/"$DOMAINUSER"/public_html/yap/config.php

    sed -i -- 's/$mysql_password = "";/$mysql_password = "'$PASSWD'";/g' /home/"$DOMAINUSER"/public_html/yap/config.php

    sed -i -- 's/$mysql_database = "";/$mysql_database = "'$YAPDB'";/g' /home/"$DOMAINUSER"/public_html/yap/config.php

    #edit .htaccess so yap will run under virtualmin
    echo "Editing .htaccess for yap"
    sed -i -- 's/Options +FollowSymLinks/Options +SymLinksIfOwnerMatch/g' /home/"$DOMAINUSER"/public_html/yap/.htaccess
fi

read -p "Do you want to install BMLT Root Server? (y or n) n " INSTALLBMLT
if [ "$INSTALLBMLT" = "y" ]; then
    echo "BMLT Root Server Install"
    #BMLT Root Server Installation
    echo "Creating database"
    #set database name
    BMLTDB="bmlt_$DOMAINUSER"
    reate database
    virtualmin create-database --domain $DOMAIN --name $BMLTDB --type mysql
    echo "Downloading and Preparing files"
    cd /home/"$DOMAINUSER"/public_html/
    #downlaoad latest stable version of BMLT Root Server
    curl -s https://api.github.com/repos/bmlt-enabled/bmlt-root-server/releases/latest | jq -r .assets[] | jq -r .browser_download_url | wget -i -
    unzip ./bmlt-root-server.zip
    wget -cO - https://raw.githubusercontent.com/rdtripp/bmlt_ubuntu_virtualmin/master/htaccess_main_server >  /home/"$DOMAINUSER"/public_html/main_server/.htaccess
    chown -R "$DOMAINUSER":"$DOMAINUSER" ./main_server
    rm *zip
fi

echo "To access virtualmin go to https://$(hostname -f):10000 and log in as root"

if [ "$INSTALLWP" = "y" ]; then
    echo " To access WordPress Admin go to https://$DOMAIN/wp-admin/ using the credentials you supplied during setup"
fi

if [ "$INSTALLYAP" = "y" ]; then
    echo " To initailize the Yap Database go to https://$DOMAIN/yap/upgrade-advisor.php"
    echo " To access Yap Admin Console go to https://$DOMAIN/yap/admin/"
fi

if [ "$INSTALLBMLT" = "y" ]; then
    echo "make note of the following info to set up the BMLT root server"
    echo "BMLT database: $BMLTDB"
    echo "BMLT database user: $DOMAINUSER"
    echo " To set up your BMLT Root Server go to https://$DOMAIN/main_server/"
fi

echo "Setup completed successfully!!"
echo "Please reboot"
