#!/bin/bash
clear
echo "Starting Installation"
#Fixes a bug that sets wrong permissions on /tmp 
chown root:root /tmp
chmod ugo+rwXt /tmp

echo "Enable Strict DNS Checking?  Select 1 or 2"
    select yn in "Yes" "No"; do
    case $yn in
        Yes ) DNSCHECK=y;break;;
        No ) break;;
        *) echo "you have made an invalid entry, please select option 1 or 2";;
    esac
   done
   
#Get public ip address of droplet
echo "Getting public ip address of droplet"
PUBIP=$(curl ipinfo.io/ip); echo "The public IP address is $PUBIP"echo "Adding additional packages"

echo
echo

echo "Verifying dns record for droplet"

echo "Getting Reverse DNS from Public IP Address"
DNSHOSTLOOKUP=$(dig -x $PUBIP +short)

#Removing "." 
VIRTHOSTDNS="${DNSHOSTLOOKUP::-1}"

echo "Getting full hostname from Droplet"   #Updates system to reflect new sources added by installs
VIRTHOST=$(hostname -f)

echo "Comparing full hostname to reverse dns" 
if [[ $VIRTHOSTDNS != $VIRTHOST ]]; then
        echo "dns for virtual host $(hostname -f) is not set up correctly, please correct the problem and run the install script again";
        exit
fi
echo "The dns record for virtual host $(hostname -f) is set up correctly"
echo


#Input Virtual Server info
while :
do
        echo "Enter FQDN for Virtual Server:"
        read DOMAIN
        if [[ $DOMAIN = "" ]]; then
            echo "You have not entered a domain name."
            echo "Please try again."-
            continue
        else
            break

        fi
done

echo "Checking dns records for Virtual server $DOMAIN"
echo
for INDEX in {1..6}
do
   IPCHECK=$(dig +short $DOMAIN);
   if [[ $IPCHECK != $PUBIP ]]; then
        echo "$INDEX No dns record for $DOMAIN found reconciling to $PUBIP, trying again";sleep 5 
       else
           break
       fi
   if [[ $INDEX = 6 ]]; then
      echo "No dns record for $DOMAIN found reconciling to $PUBIP, exiting";exit
      fi
done

echo "$DOMAIN  dns is set up correctly";

DOMAINUSER=`echo "$DOMAIN" | cut -d'.' -f 1`

echo "The user for domain $DOMAIN is user $DOMAINUSER"

while :
do
        echo "Enter a password for user $DOMAINUSER:   "
        read PASSWD
           if [[ $PASSWD = "" ]]
               then   #Updates system to reflect new sources added by installs
    apt-get update && apt-get -y upgrade
                  echo "You have not entered a password."
                  echo "Please try again."
                  continue
              else
                  break
         fi
done

echo "Checking dns records for www.$DOMAIN"
IPCHECKWWW=$(dig +short www.$DOMAIN);
echo
echo 
WWW=1
if [[ $IPCHECKWWW != $PUBIP ]]; then
        echo "www.$DOMAIN dns is not configured correctly. this is recommended but not essential";
        echo;WWW=0
        echo "do you want to continue? select 1 or 2"
        select yn in "Yes" "No"; do
    case $yn in   #Updates system to reflect new sources added by installs
        Yes ) break;;
        No ) exit;;
        *) echo "you have made an invalid entry, please select option 1 or 2";;
    esac
  done  
fi
echo
echo

echo "Checking dns records for mail.$DOMAIN"
IPCHECKMAIL=$(dig +short mail.$DOMAIN)
echo
echo
MAIL=1
if [[ $IPCHECKMAIL != $PUBIP ]]; then
        echo "mail.$DOMAIN dns is not configured correctly. this is not essential";
        echo   #Updates system to reflect new sources added by installs
    apt-get update && apt-get -y upgrade
        echo "do you want to continue? select 1 or 2";MAIL=0
        select yn in "Yes" "No"; do
    case $yn in
        Yes ) break;;
        No ) exit;;
        *) echo "you have made an invalid entry, please select option 1 or 2";;
   esac
 done  
fi

clear

#Set correct time zone
dpkg-reconfigure tzdata

echo "Virtualmin Minimal is adequate for this application and takes less resources"
echo "Only choose Virtualmin Full if you need the extra features and know what you are doing"
echo
echo "Which version of Virtualmin do you want to install? select 1 or 2"
select yn in "Minimal" "Full"; do
    case $yn in   
        Minimal ) VMINMIN=y;break;;
        Full ) break;;
        *) echo "Error select option 1 or 2";;
    esac
done

echo "Install certificate from Letsencrypt? select 1 or 2"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) INSTALLLE=y;break;;
        No ) break;;
        *) echo "you have made an invalid entry, please select option 1 or 2";;
    esac 
done  
  
  #WordPress Install
 echo "Do you want to install WordPress? select 1 or 2"
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
             else
                 break
        fi
   done
 fi
   
 #WordPress Multisite
 if [ "$INSTALLWP" = "y" ]; then
     echo "Do you want to enable WordPress Multisite? Select 1 or 2"
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

echo "Do you want to install Yap?  Select 1 or 2"
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



        #make a swap file
        echo "configuring swap file"
        dd if=/dev/zero of=/swapfile bs=1k count=2048k
        chmod 600 /swapfile
        mkswap /swapfile
        swapon /swapfile
        echo "/swapfile swap swap defaults 0 0" >> /etc/fstabecho "Adding additional packages"
        echo "vm.swappiness=10" >> /etc/sysctl.conf


echo "Starting Virtualmin Installati#Add additional packages
echo "Adding additional packages"
apt install -y php-curl php-gd php-mbstring php-xml php-xmlrpc jq bind9-hoston"

echo "Downloading Virtualmin install script"
wget http://software.virtualmin.com/gpl/scripts/install.sh

if [ $VMINMIN = "y" ]; then
        sh ./install.sh -f -v -m;
    else
        sh ./install.sh -f -v;
fi

echo "Creating virtual server"
#Start virtual server install
virtualmin create-domain --domain $DOMAIN --pass $PASSWD --desc "BMLT DEV" --unix --dir --webmin  --web --ssl --mysql --dns --mail --limits-from-plan
#End virtual server install
echo "Adding additional packages"
apt install -y php-curl php-gd php-mbstring php-xml php-xmlrpc
echo "Adding $DOMAINUSER to sudoers"
usermod -aG sudo $DOMAINUSER

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

echo "Adding additional packages"
apt install -y php-curl php-gd php-mbstring php-xml php-xmlrpc

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
    curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
    chmod +x wp-cli.phar
    sudo mv wp-cli.phar /usr/local/bin/wp
    #End Wordpress CLI install
    
    echo "Editing php.ini to accomidate uploads to WordPress"
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
        
        echo "Installing WordPress Plugins"
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
echo    echo "Downloading YAP & Preparing files"
421
    #Get YAP
422
    mkdir /home/"$DOMAINUSER"/public_html/yap
423
    #Download latest yap stable
424
    curl -s https://api.github.com/repos/bmlt-enabled/yap/releases/latest | jq -r .assets[] | jq -r .browser_download_url | wget -i - 
425
    unzip yap*.zip -d /home/"$DOMAINUSER"/public_html/yap/
426
    rm *.zip
427
    chown -R "$DOMAINUSER":"$DOMAINUSER" /home/"$DOMAINUSER"/public_html/*
428
    echo "Configuring YAP"
429
    #Configure yap
430
    sed -i -- 's/$title = "";/$title = "'"$TITLE"'";/g' /home/"$DOMAINUSER"/public_html/yap/config.php
431
    sed -i -- 's+$bmlt_root_server = "";+$bmlt_root_server = "'$ROOTSVR'";+g' /home/"$DOMAINUSER"/public_html/yap/config.php
432
    sed -i -- 's/$google_maps_api_key = "";/$google_maps_api_key = "'$GMAPAPI'";/g' /home/"$DOMAINUSER"/public_html/yap/config.php
433
    sed -i -- 's/twilio_account_sid = "";/twilio_account_sid = "'$TWILACCTSID'";/g' /home/"$DOMAINUSER"/public_html/yap/config.php
434
    sed -i -- 's/$twilio_auth_token = "";/$twilio_auth_token = "'$TWILAUTHTOK'";/g' /home/"$DOMAINUSER"/public_html/yap/config.php
435
    sed -i -- 's/$bmlt_username = "";/$bmlt_username = "'$BMLTUSR'";/g' /home/"$DOMAINUSER"/public_html/yap/config.php
436
    sed -i -- 's/$bmlt_password = "";/$bmlt_password = "'$BMLTPASS'";/g' /home/"$DOMAINUSER"/public_html/yap/config.php
437
    sed -i -- 's/$mysql_hostname = "";/$mysql_hostname = "localhost";/g' /home/"$DOMAINUSER"/public_html/yap/config.php
438
    sed -i -- 's/$mysql_username = "";/$mysql_username = "'$DOMAINUSER'";/g' /home/"$DOMAINUSER"/public_html/yap/config.php
439
    sed -i -- 's/$mysql_password = "";/$mysql_password = "'$PASSWD'";/g' /home/"$DOMAINUSER"/public_html/yap/config.php
440
    sed -i -- 's/$mysql_database = "";/$mysql_database = "'$YAPDB'";/g' /home/"$DOMAINUSER"/public_html/yap/config.php
441
    #edit .htaccess so yap will run under virtualmin
442
    echo "Editing .htaccess for yap"
443
    sed -i -- 's/Options +FollowSymLinks/Options +SymLinksIfOwnerMatch/g' /home/"$DOMAINUSER"/public_html/yap/.htaccess
444
fi
445
echo
446
echo
447
echo
448
clear
449
echo  "Please make a copy of the following information:"
450
echo
451
echo
452
echo "The virtual Server $DOMAIN has user $DOMAINUSER with password $PASSWD"
453
echo
454
echo "To access virtualmin go to https://$(hostname -f):10000 and log in as root or $ADMINUSER"
455
echo
456
if [ "$INSTALLWP" = "y" ]; then
457
    echo " To access WordPress Admin go to https://$DOMAIN/wp-admin/ and log in using user $WPADMIN and password $WPADMINPASS"
458
fi
459
echo
460
if [ "$INSTALLYAP" = "y" ]; then
461
    echo "Checking Yap configuration and initializing database";
462
    echo 
463
    curl -k https://$DOMAIN/yap/upgrade-advisor.php;
464
    echo
465
    echo
466
    echo "To access Yap Admin Console go to https://$DOMAIN/yap/admin/";
467
fi
468
echo
469
echo
470
if [ "$INSTALLBMLT" = "y" ]; then
471
    echo "Make note of the following info to set up the BMLT root server:"
472
    echo
473
    echo "BMLT    echo "Downloading YAP & Preparing files"
421
    #Get YAP
422
    mkdir /home/"$DOMAINUSER"/public_html/yap
423
    #Download latest yap stable
424
    curl -s https://api.github.com/repos/bmlt-enabled/yap/releases/latest | jq -r .assets[] | jq -r .browser_download_url | wget -i - 
425
    unzip yap*.zip -d /home/"$DOMAINUSER"/public_html/yap/
426
    rm *.zip
427
    chown -R "$DOMAINUSER":"$DOMAINUSER" /home/"$DOMAINUSER"/public_html/*
428
    echo "Configuring YAP"
429
    #Configure yap
430
    sed -i -- 's/$title = "";/$title = "'"$TITLE"'";/g' /home/"$DOMAINUSER"/public_html/yap/config.php
431
    sed -i -- 's+$bmlt_root_server = "";+$bmlt_root_server = "'$ROOTSVR'";+g' /home/"$DOMAINUSER"/public_html/yap/config.php
432
    sed -i -- 's/$google_maps_api_key = "";/$google_maps_api_key = "'$GMAPAPI'";/g' /home/"$DOMAINUSER"/public_html/yap/config.php
433
    sed -i -- 's/twilio_account_sid = "";/twilio_account_sid = "'$TWILACCTSID'";/g' /home/"$DOMAINUSER"/public_html/yap/config.php
434
    sed -i -- 's/$twilio_auth_token = "";/$twilio_auth_token = "'$TWILAUTHTOK'";/g' /home/"$DOMAINUSER"/public_html/yap/config.php
435
    sed -i -- 's/$bmlt_username = "";/$bmlt_username = "'$BMLTUSR'";/g' /home/"$DOMAINUSER"/public_html/yap/config.php
436
    sed -i -- 's/$bmlt_password = "";/$bmlt_password = "'$BMLTPASS'";/g' /home/"$DOMAINUSER"/public_html/yap/config.php
437
    sed -i -- 's/$mysql_hostname = "";/$mysql_hostname = "localhost";/g' /home/"$DOMAINUSER"/public_html/yap/config.php
438
    sed -i -- 's/$mysql_username = "";/$mysql_username = "'$DOMAINUSER'";/g' /home/"$DOMAINUSER"/public_html/yap/config.php
439
    sed -i -- 's/$mysql_password = "";/$mysql_password = "'$PASSWD'";/g' /home/"$DOMAINUSER"/public_html/yap/config.php
440
    sed -i -- 's/$mysql_database = "";/$mysql_database = "'$YAPDB'";/g' /home/"$DOMAINUSER"/public_html/yap/config.php
441
    #edit .htaccess so yap will run under virtualmin
442
    echo "Editing .htaccess for yap"
443
    sed -i -- 's/Options +FollowSymLinks/Options +SymLinksIfOwnerMatch/g' /home/"$DOMAINUSER"/public_html/yap/.htaccess
444
fi
445
echo
446
echo
447
echo
448
clear
449
echo  "Please make a copy of the following information:"
450
echo
451
echo
452
echo "The virtual Server $DOMAIN has user $DOMAINUSER with password $PASSWD"
453
echo
454
echo "To access virtualmin go to https://$(hostname -f):10000 and log in as root or $ADMINUSER"
455
echo
456
if [ "$INSTALLWP" = "y" ]; then
457
    echo " To access WordPress Admin go to https://$DOMAIN/wp-admin/ and log in using user $WPADMIN and password $WPADMINPASS"
458
fi
459
echo
460
if [ "$INSTALLYAP" = "y" ]; then
461
    echo "Checking Yap configuration and initializing database";
462
    echo 
463
    curl -k https://$DOMAIN/yap/upgrade-advisor.php;
464
    echo
465
    echo
466
    echo "To access Yap Admin Console go to https://$DOMAIN/yap/admin/";
467
fi
468
echo
469
echo
470
if [ "$INSTALLBMLT" = "y" ]; then
471
    echo "Make note of the following info to set up the BMLT root server:"
472
    echo
473
    echo "BMLT    echo "Downloading YAP & Preparing files"
421
    #Get YAP
422
    mkdir /home/"$DOMAINUSER"/public_html/yap
423
    #Download latest yap stable
424
    curl -s https://api.github.com/repos/bmlt-enabled/yap/releases/latest | jq -r .assets[] | jq -r .browser_download_url | wget -i - 
425
    unzip yap*.zip -d /home/"$DOMAINUSER"/public_html/yap/
426
    rm *.zip
427
    chown -R "$DOMAINUSER":"$DOMAINUSER" /home/"$DOMAINUSER"/public_html/*
428
    echo "Configuring YAP"
429
    #Configure yap
430
    sed -i -- 's/$title = "";/$title = "'"$TITLE"'";/g' /home/"$DOMAINUSER"/public_html/yap/config.php
431
    sed -i -- 's+$bmlt_root_server = "";+$bmlt_root_server = "'$ROOTSVR'";+g' /home/"$DOMAINUSER"/public_html/yap/config.php
432
    sed -i -- 's/$google_maps_api_key = "";/$google_maps_api_key = "'$GMAPAPI'";/g' /home/"$DOMAINUSER"/public_html/yap/config.php
433
    sed -i -- 's/twilio_account_sid = "";/twilio_account_sid = "'$TWILACCTSID'";/g' /home/"$DOMAINUSER"/public_html/yap/config.php
434
    sed -i -- 's/$twilio_auth_token = "";/$twilio_auth_token = "'$TWILAUTHTOK'";/g' /home/"$DOMAINUSER"/public_html/yap/config.php
435
    sed -i -- 's/$bmlt_username = "";/$bmlt_username = "'$BMLTUSR'";/g' /home/"$DOMAINUSER"/public_html/yap/config.php
436
    sed -i -- 's/$bmlt_password = "";/$bmlt_password = "'$BMLTPASS'";/g' /home/"$DOMAINUSER"/public_html/yap/config.php
437
    sed -i -- 's/$mysql_hostname = "";/$mysql_hostname = "localhost";/g' /home/"$DOMAINUSER"/public_html/yap/config.php
438
    sed -i -- 's/$mysql_username = "";/$mysql_username = "'$DOMAINUSER'";/g' /home/"$DOMAINUSER"/public_html/yap/config.php
439
    sed -i -- 's/$mysql_password = "";/$mysql_password = "'$PASSWD'";/g' /home/"$DOMAINUSER"/public_html/yap/config.php
440
    sed -i -- 's/$mysql_database = "";/$mysql_database = "'$YAPDB'";/g' /home/"$DOMAINUSER"/public_html/yap/config.php
441
    #edit .htaccess so yap will run under virtualmin
442
    echo "Editing .htaccess for yap"
443
    sed -i -- 's/Options +FollowSymLinks/Options +SymLinksIfOwnerMatch/g' /home/"$DOMAINUSER"/public_html/yap/.htaccess
444
fi
445
echo
446
echo
447
echo
448
clear
449
echo  "Please make a copy of the following information:"
450
echo
451
echo
452
echo "The virtual Server $DOMAIN has user $DOMAINUSER with password $PASSWD"
453
echo
454
echo "To access virtualmin go to https://$(hostname -f):10000 and log in as root or $ADMINUSER"
455
echo
456
if [ "$INSTALLWP" = "y" ]; then
457
    echo " To access WordPress Admin go to https://$DOMAIN/wp-admin/ and log in using user $WPADMIN and password $WPADMINPASS"
458
fi
459
echo
460
if [ "$INSTALLYAP" = "y" ]; then
461
    echo "Checking Yap configuration and initializing database";
462
    echo 
463
    curl -k https://$DOMAIN/yap/upgrade-advisor.php;
464
    echo
465
    echo
466
    echo "To access Yap Admin Console go to https://$DOMAIN/yap/admin/";
467
fi
468
echo
469
echo
470
if [ "$INSTALLBMLT" = "y" ]; then
471
    echo "Make note of the following info to set up the BMLT root server:"
472
    echo
473
    echo "BMLT database: $BMLTDB"
474
    echo "BMLT database user: $DOMAINUSER"
475
    echo "BMLT database password:  $PASSWD"
476
    echo "Google Maps API:  $GMAPAPI"
477
    echo
478
    echo " To set up your BMLT Root Server go to https://$DOMAIN/main_server/"
479
fi
480
echo
481
echo
482
echo "A reboot is required"
483
read -p "Do you want to reboot now? (y or n) n     "    REBOOT
484
if [ "$REBOOT" = "y" ]; then
485
    halt --reboot
486
fi     database: $BMLTDB"
474
    echo "BMLT database user: $DOMAINUSER"
475
    echo "BMLT database password:  $PASSWD"
476
    echo "Google Maps API:  $GMAPAPI"
477
    echo
478
    echo " To set up your BMLT Root Server go to https://$DOMAIN/main_server/"
479
fi
480
echo
481
echo
482
echo "A reboot is required"
483
read -p "Do you want to reboot now? (y or n) n     "    REBOOT
484
if [ "$REBOOT" = "y" ]; then
485
    halt --reboot
486
fi     database: $BMLTDB"
474
    echo "BMLT database user: $DOMAINUSER"
475
    echo "BMLT database password:  $PASSWD"
476
    echo "Google Maps API:  $GMAPAPI"
477
    echo
478
    echo " To set up your BMLT Root Server go to https://$DOMAIN/main_server/"
479
fi
480
echo
481
echo
482
echo "A reboot is required"
483
read -p "Do you want to reboot now? (y or n) n     "    REBOOT
484
if [ "$REBOOT" = "y" ]; then
485
    halt --reboot
486
fi    
echo "The virtual Server $DOMAIN has user $DOMAINUSER with password $PASSWD"
echo
echo "To access virtualmin go to https://$(hostname -f):10000 and log in as root or $ADMINUSER"
echo
if [ "$INSTALLWP" = "y" ]; then
    echo " To access WordPress Admin go to https://$DOMAIN/wp-admin/ and log in using user $WPADMIN and password $WPADMINPASS"
fi
echo
if [ "$INSTALLYAP" = "y" ]; then
    echo "Checking Yap configuration and initializing database";
    echo 
    curl -k https://$DOMAIN/yap/upgrade-advisor.php;
    echo
    echo
    echo "To access Yap Admin Console go to https://$DOMAIN/yap/admin/";
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
