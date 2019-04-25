#!/bin/bash
clear
echo "Starting Installation"
#Fixes a bug that sets wrong permissions on /tmp 
chown root:root /tmp
chmod ugo+rwXt /tmp

#Get public ip address of droplet
echo "Getting public ip address of droplet"
PUBIP=$(curl ipinfo.io/ip); echo "The public IP address is $PUBIP"
echo
echo
#Verify droplet has dns set up correctly
#Getting Reverse DNS from Public IP Address
DNSHOSTLOOKUP=$(dig -x $PUBIP +short)
#Removing "." 
VIRTHOSTDNS="${DNSHOSTLOOKUP::-1}"
#Get full hostname from Droplet
VIRTHOST=$(hostname -f)
#Compare full hostname to reverse dns 
if [[ $VIRTHOSTDNS != $VIRTHOST ]]; then
        echo "dns for virtual host $(hostname -f) is not set up correctly, please correct the problem and run the install script again";
        exit
fi
echo "dns for virtual host $(hostname -f) is set up correctly"
echo


#Input Virtual Server info
while :
do
        echo "Enter FQDN for Virtual Server:"
        read DOMAIN
        if [[ $DOMAIN = "" ]]; then
        echo "You have not entered a domain name."
        echo "Please try again."
        continue

        else
        break

        fi
done

while :
do
        echo "Enter a password for the $DOMAIN user:"
        read PASSWD
        if [[ $PASSWD = "" ]]

        then
        echo "You have not entered a password."
        echo "Please try again."
        continue

        else
        break

        fi
done

#Verify Virtual server has dns set up correctly
echo
echo
IPCHECK=$(dig +short $DOMAIN);
if [[ $IPCHECK != $PUBIP ]]; then
        echo "dns for virtual server $DOMAIN is not set up correctly, please correct the problem and run the install script again";
        exit
fi
echo "$DOMAIN  dns set up correctly";

#Check for www, in dns
IPCHECKWWW=$(dig +short www.$DOMAIN);
echo
echo
WWW=1
if [[ $IPCHECKWWW != $PUBIP ]]; then
        echo "www.$DOMAIN dns is not configured correctly. this is recommended but not essential";
        echo;WWW=0
        echo "do you want to continue? select 1 or 2"
        select yn in "Yes" "No"; do
    case $yn in
        Yes ) break;;
        No ) exit;;
        *)
                echo "you have made an invalid entry, please select option 1 or 2";;
    esac
    done
fi
echo
echo

#check for mail.$DOMAIN in dns
IPCHECKMAIL=$(dig +short mail.$DOMAIN)
echo
echo
MAIL=1
if [[ $IPCHECKMAIL != $PUBIP ]]; then
        echo "mail.$DOMAIN dns is not configured correctly. this is not essential";
        echo
        echo "do you want to continue? select 1 or 2";MAIL=0
        select yn in "Yes" "No"; do
    case $yn in
        Yes ) break;;
        No ) exit;;
        *)
                echo "you have made an invalid entry, please select option 1 or 2";;
    esac
    done
fi

#make a swap file
echo "configuring swap file"
dd if=/dev/zero of=/swapfile bs=1k count=2048k
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo "/swapfile swap swap defaults 0 0" >> /etc/fstab
echo "vm.swappiness=10" >> /etc/sysctl.conf 

clear
#Add admin "sudo"user
echo " Add a sudo user.  Do NOT use your domain name or any portion of it!"
while :
do
        echo "Enter a name for the sudo user:"
        read ADMINUSER
        if [[ $ADMINUSER = "" ]]

        then
        echo "You have not entered a USER name."
        echo "Please try again."
        continue

        else
        break

        fi
done

while :
do
        echo "Enter a password for the sudo user:"
        read ADMINPASS
        if [[ $ADMINPASS = "" ]]

        then
        echo "You have not entered a password."
        echo "Please try again."
        continue

        else
        break

        fi
done

echo "configuring sudo user
useradd $ADMINUSER -m -p $ADMINPASS
usermod -aG sudo $ADMINUSER

#Set correct time zone
dpkg-reconfigure tzdata

echo "Install certificate from Letsencrypt? select 1 or 2"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) INSTALLLE=y;break;;
        No ) INSTALLLE=n;break;;
        *) echo "you have made an invalid entry, please select option 1 or 2";;
    esac
  done
  
  #WordPress Install
 echo "Install WordPress? select 1 or 2"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) INSTALLWP=y;break;;
        No ) INSTALLWP=n;break;;
        *) echo "you have made an invalid entry, please select option 1 or 2";;
    esac
done

if [ "$INSTALLWP" = "y" ]; then
    while :
        do
            echo "Enter a name for the WordPress Admin user:"
            read WPADMIN
            if [[ $WPADMIN = "" ]]

            then
            echo "You have not entered a user name."
            echo "Please try again."
            continue

            else
            break
            fi
           
    done

    while :
        do
            echo "Enter a password for the WordPress Admin user:"
            read WPADMINPASS
           if [[ $WPADMINPASS = "" ]]

            then
            echo "You have not entered a password."
            echo "Please try again."
            continue

            else
            break

         fi
    done

while :
    do
            echo "Enter a name for the WordPress site:"
            read WPSITENAME
            if [[ $WPSITENAME = "" ]]

            then
            echo "You have not entered a valid site name."
            echo "Please try again."
            continue

            else
          break

        fi
   done
   fi
   
 #WordPress Multisite
 if [ "$INSTALLWP" = "y" ]; then
     echo "Enable WordPress Multisite? Select 1 or 2"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) INSTALLWPMS=y;break;;
        No ) INSTALLWPMS=n;break;;
        *) echo "you have made an invalid entry,please select option 1 or 2";;
    esac
done
   fi
   
echo "Do you want to install a BMLT Root Server? Select 1 or 2"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) INSTALLBMLT=y;read -p "Enter your Google Maps API key:   "  GMAPAPI;break;;
        No ) INSTALLBMLT=n;break;;
        *) echo "you have made an invalid entry, please select option 1 or 2";;
    esac
done

echo "Install Yap?  Select 1 or 2"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) INSTALLYAP=y;break;;
        No ) INSTALLYAP=n;break;;
        *) echo "you have made an invalid entry, please select option 1 or 2";;
    esac
done
    
 if [ "$INSTALLYAP" = "y" ]; then   
    read -p "Enter Phone Greeting, "title" in config.php:  "  TITLE

    read -p "Enter your BMLT root server:   "  ROOTSVR

    read -p "Enter your Google Maps API key:   "  GMAPAPI

    read -p "Enter your twilio account sid:   "  TWILACCTSID

    read -p "Enter your twilio Auth Token:   " TWILAUTHTOK

    read -p "Enter your BMLT root server user name:   "  BMLTUSR

    read -p "Enter your BMLT root server password:   "  BMLTPASS
fi

#Start LAMP install
echo "Gathering Required Information for LAMP install"
echo
echo
echo "Starting Virtualmin Installation"
#Starts Virtualmin install
#Downloads Virtualmin install script
wget http://software.virtualmin.com/gpl/scripts/install.sh
echo "Select the version of Virtualmin you want to install"
echo "Virtualmin Minimal is adequate for this application and takes less resources"
echo "Only choose Virtualmin Full if you need the extra features and know what you are doing"
echo
select version in "Minimal" "Full"; do
    case $version in   
        Minimal ) sh ./install.sh -f -v -m;break;;
        Full ) sh ./install.sh -f -v;break;;
        *) echo "Error select option 1 or 2";;
    esac
done
#End Virtualmin Install

echo "Creating virtual server"
#Start virtual server install
DOMAINUSER=`echo "$DOMAIN" | cut -d'.' -f 1`

virtualmin create-domain --domain $DOMAIN --pass $PASSWD --desc "BMLT DEV" --unix --dir --webmin  --web --ssl --mysql --dns --mail --limits-from-plan
#End virtual domain install

#Add additional packages
echo "Adding additional packages"
apt install -y php-curl php-gd php-mbstring php-xml php-xmlrpc jq bind9-host

echo
echo
echo

if [ "$INSTALLLE" = "y" ]; then
echo "installing certificate from Letsencrypt"
    if [ "$WWW" = "1" ] && [ "$MAIL" = "1" ]; then
        /usr/share/webmin/virtual-server/generate-letsencrypt-cert.pl --domain $DOMAIN --validate-first --host $DOMAIN --renew 2  --host www.$DOMAIN --renew 2 --host mail.$DOMAIN --renew 2
        fi
    if [ "$WWW" = "1" ] && [ "$MAIL" != "1" ]; then
        /usr/share/webmin/virtual-server/generate-letsencrypt-cert.pl --domain $DOMAIN --validate-first --host $DOMAIN --renew 2  --host www.$DOMAIN --renew 2
        fi
    if [ "$WWW" != "1" ] && [ "$MAIL" = "1" ]; then
        /usr/share/webmin/virtual-server/generate-letsencrypt-cert.pl --domain $DOMAIN --validate-first --host $DOMAIN --renew 2  --host mail.$DOMAIN --renew 2
        fi
    if [ "$WWW" != "1" ] && [ "$MAIL" != "1" ]; then
        /usr/share/webmin/virtual-server/generate-letsencrypt-cert.pl --domain $DOMAIN --validate-first --host $DOMAIN --renew 2
        fi
fi
if [ "$INSTALLWP" = "y" ]; then
    echo "Installing WordPress"
    #Install WordPress
    #set wordpress database name
    WPDB="wp_$DOMAINUSER"
    # create database for wordpress
    echo "Creating WordPress database"
    virtualmin create-database --domain $DOMAIN --name $WPDB --type mysql
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
    echo
    echo
    echo "installing Wordress CLI"
    #Install Wordpress CLI
    apt-get update && apt-get -y install curl
    curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
    chmod +x wp-cli.phar
    sudo mv wp-cli.phar /usr/local/bin/wp
    #End Wordpress CLI install
    #Edit php.ini
    sed -i -- 's/upload_max_filesize = 2M/upload_max_filesize = 720M/g' /home/"$DOMAINUSER"/etc/php.ini
    sed -i -- 's/post_max_size = 8M/post_max_size = 64M/g' /home/"$DOMAINUSER"/etc/php.ini
    sed -i -- 's/memory_limit = 128M/memory_limit = 1024M/g' /home/"$DOMAINUSER"/etc/php.ini
    sed -i -- 's/max_execution_time = 40/max_execution_time = 180/g' /home/"$DOMAINUSER"/etc/php.ini
fi
echo
echo
echo


    if [ "$INSTALLWPMS" = "y" ]; then
        echo "Configuring WordPress as multisite"
        #Configure WordPress multisite
        sudo -u $DOMAINUSER wp core multisite-install --path=/home/"$DOMAINUSER"/public_html/ --url=http://"$DOMAIN"/ --title="$WPSITENAME" --admin_user=$WPADMIN --admin_password=$WPADMINPASS --admin_email=$DOMAINUSER@$DOMAIN
        echo "configuring .htaccess for WordPress multisite"
        cat ./htaccess >  /home/"$DOMAINUSER"/public_html/.htaccess

        echo "Installin WordPress Plugins"
        #install WordPress Plugins
        sudo -u "$DOMAINUSER" -i -- wp --path=/home/"$DOMAINUSER"/public_html/ plugin install bmlt-wordpress-satellite-plugin --activate-network
        sudo -u "$DOMAINUSER" -i -- wp --path=/home/"$DOMAINUSER"/public_html/ plugin install bread --activate-network
        sudo -u "$DOMAINUSER" -i -- wp --path=/home/"$DOMAINUSER"/public_html/ plugin install crouton --activate-network
        sudo -u "$DOMAINUSER" -i -- wp --path=/home/"$DOMAINUSER"/public_html/ plugin install bmlt-tabbed-map --activate-network
        sudo -u "$DOMAINUSER" -i -- wp --path=/home/"$DOMAINUSER"/public_html/ plugin install wp-force-ssl --activate-network    
     fi 

echo
echo
echo

if [ "$INSTALLWPMS" != "y" ] && [ "$INSTALLWP" = "y" ]; then
    sudo -u $DOMAINUSER wp core install --path=/home/"$DOMAINUSER"/public_html/ --url=http://"$DOMAIN"/ --title="$WPSITENAME" --admin_user=$WPADMIN --admin_password=$WPADMINPASS --admin_email=$DOMAINUSER@$DOMAIN
    sudo -u "$DOMAINUSER" -i -- wp --path=/home/"$DOMAINUSER"/public_html/ plugin install bmlt-wordpress-satellite-plugin --activate
    sudo -u "$DOMAINUSER" -i -- wp --path=/home/"$DOMAINUSER"/public_html/ plugin install bread --activate
    sudo -u "$DOMAINUSER" -i -- wp --path=/home/"$DOMAINUSER"/public_html/ plugin install crouton --activate
    sudo -u "$DOMAINUSER" -i -- wp --path=/home/"$DOMAINUSER"/public_html/ plugin install bmlt-tabbed-map --activate
    sudo -u "$DOMAINUSER" -i -- wp --path=/home/"$DOMAINUSER"/public_html/ plugin install wp-force-ssl --activate
fi
echo
echo

if [ "$INSTALLBMLT" = "y" ]; then   
    echo "BMLT Root Server Install"
    #BMLT Root Server Installation
    echo "Creating database"
    #Set database name
    BMLTDB="bmlt_$DOMAINUSER"
    #Create database
    virtualmin create-database --domain $DOMAIN --name $BMLTDB --type mysql
    echo "Downloading and Preparing files"
    #downlaoad latest stable version of BMLT Root Server
    curl -s https://api.github.com/repos/bmlt-enabled/bmlt-root-server/releases/latest | jq -r .assets[] | jq -r .browser_download_url | wget -i -
    unzip ./bmlt-root-server.zip -d /home/"$DOMAINUSER"/public_html/
    cat ./htaccess_main_server >  /home/"$DOMAINUSER"/public_html/main_server/.htaccess
    chown -R "$DOMAINUSER":"$DOMAINUSER" /home/"$DOMAINUSER"/public_html/main_server
    rm *zip
fi 
if [ "$INSTALLBMLT" = "y" ]; then
    echo "Make note of the following info to set up the BMLT root server:"
    echo
    echo "BMLT database: $BMLTDB"
    echo "BMLT database user: $DOMAINUSER"
    echo "BMLT database password:  $PASSWD"
    echo "Google Maps API:  $GMAPAPI"
    echo
    echo " To set up your BMLT Root Server go to https://$DOMAIN/main_server/"
fi

if [ "$INSTALLYAP" = "y" ]; then
    #Updates system to reflect new sources added by installs
    apt-get update && apt-get -y upgrade
    echo "Starting Yap Installation"
    #set yap database name
    YAPDB="yap_$DOMAINUSER"
    echo "Creating YAP database"
    #create database for YAP
    virtualmin create-database --domain $DOMAIN --name $YAPDB --type mysql

    echo "Downloading YAP & Preparing files"
    #Get YAP
    mkdir /home/"$DOMAINUSER"/public_html/yap
    #Download latest yap stable
    curl -s https://api.github.com/repos/bmlt-enabled/yap/releases/latest | jq -r .assets[] | jq -r .browser_download_url | wget -i - 
    unzip yap*.zip -d /home/"$DOMAINUSER"/public_html/yap/
    rm *.zip
    chown -R "$DOMAINUSER":"$DOMAINUSER" /home/"$DOMAINUSER"/public_html/*

    echo "Configuring YAP"
    #Configure yap
    sed -i -- 's/$title = "";/$title = "'"$TITLE"'";/g' /home/"$DOMAINUSER"/public_html/yap/config.php

    sed -i -- 's+$bmlt_root_server = "";+$bmlt_root_server = "'$ROOTSVR'";+g' /home/"$DOMAINUSER"/public_html/yap/config.php

    sed -i -- 's/$google_maps_api_key = "";/$google_maps_api_key = "'$GMAPAPI'";/g' /home/"$DOMAINUSER"/public_html/yap/config.php

    sed -i -- 's/twilio_account_sid = "";/twilio_account_sid = "'$TWILACCTSID'";/g' /home/"$DOMAINUSER"/public_html/yap/config.php

    sed -i -- 's/$twilio_auth_token = "";/$twilio_auth_token = "'$TWILAUTHTOK'";/g' /home/"$DOMAINUSER"/public_html/yap/config.php

    sed -i -- 's/$bmlt_username = "";/$bmlt_username = "'$BMLTUSR'";/g' /home/"$DOMAINUSER"/public_html/yap/config.php

    sed -i -- 's/$bmlt_password = "";/$bmlt_password = "'$BMLTPASS'";/g' /home/"$DOMAINUSER"/public_html/yap/config.php

    sed -i -- 's/$mysql_hostname = "";/$mysql_hostname = "localhost";/g' /home/"$DOMAINUSER"/public_html/yap/config.php

    sed -i -- 's/$mysql_username = "";/$mysql_username = "'$DOMAINUSER'";/g' /home/"$DOMAINUSER"/public_html/yap/config.php

    sed -i -- 's/$mysql_password = "";/$mysql_password = "'$PASSWD'";/g' /home/"$DOMAINUSER"/public_html/yap/config.php

    sed -i -- 's/$mysql_database = "";/$mysql_database = "'$YAPDB'";/g' /home/"$DOMAINUSER"/public_html/yap/config.php

    #edit .htaccess so yap will run under virtualmin
    echo "Editing .htaccess for yap"
    sed -i -- 's/Options +FollowSymLinks/Options +SymLinksIfOwnerMatch/g' /home/"$DOMAINUSER"/public_html/yap/.htaccess
fi

echo
echo
echo
clear
echo  "Please make a copy of the following information:"

echo
echo

echo "The virtual Server $DOMAIN has user $DOMAINUSER with password $PASSWD"

echo

echo "The sudo user is $ADMINUSER with the password $ADMINPASS"

echo

echo "To access virtualmin go to https://$(hostname -f):10000 and log in as root or $ADMINUSER"

echo

if [ "$INSTALLWP" = "y" ]; then
    echo " To access WordPress Admin go to https://$DOMAIN/wp-admin/ and log in using user $WPADMIN and password $WPADMINPASS"
fi

echo

if [ "$INSTALLYAP" = "y" ]; then
    echo "Checking Yap configuration and initializing database"; \
    echo 
    curl -k https://$DOMAIN/yap/upgrade-advisor.php; \
    echo
    echo
    echo "To access Yap Admin Console go to https://$DOMAIN/yap/admin/"; \
fi

echo
echo

if [ "$INSTALLBMLT" = "y" ]; then
    echo "Make note of the following info to set up the BMLT root server:"
    echo
    echo "BMLT database: $BMLTDB"
    echo "BMLT database user: $DOMAINUSER"
    echo "BMLT database password:  $PASSWD"
    echo "Google Maps API:  $GMAPAPI"
    echo
    echo " To set up your BMLT Root Server go to https://$DOMAIN/main_server/"
fi

echo
echo

echo "A reboot is required"
read -p "Do you want to reboot now? (y or n) n     "    REBOOT
if [ "$REBOOT" = "y" ]; then
    halt --reboot
fi    