bmlt_ubuntu_virtualmin

Description:

This project deploys an Ubuntun 18.04.2 droplet on Digital Ocean with Virtualmin and the following options:

1.  Install letsencrypt certificates

1. WordPress single site installation

2. Convert Wordpress install to multisite

3.  BMLT root setver

4.  YAP

Prerequisites:

An account with DigitalOcean https://www.digitalocean.com/

An account with twilio https://www.twilio.com/ , a phone# with them, ACCOUNT SID , & AUTH TOKEN

Google maps api key, instructions at https://bmlt.app/google-maps-api-keys-and-geolocation-issues/

A domain that you can create dns A records. You will need at mimimum a domain for the droplet such as vhost.yourdomain.xxx and a domain for the virtual server such as yourdomain.com or something.yourdomain.com. www.yourdomain.xxx for the virtual server is also recommended. If you do the full virtualmin install mail.yourdomain.xxx for the virtual server is also recommended.

Install Procedure:

Create a Ubuntu 18.04.2 Droplet (the $5.00/mo one, you can upgrade later as needed) named (for example) vhost.yourdomain.org
You will get a temp password and the fixed ip address emailed to you.

Edit your dns records for vhost.yourdomain.org (for example) and yourdomain.org, www.yourdomain.org (You can use something.yourdomain.org instead of yourdomain.org if it conflicts with an exisiting site) using the ip address of the droplet.

When dns updates, log in via terminal: ssh root@vhost.yourdomain.org and change the password
power off the server: halt --poweroff

Take a snapshot so you can revert back if you need to without having to redo dns.

Power the server back up and log back in via ssh via terminal.

Double check that you have correct dns resolution for both the droplet (host) and the virtual server or THE INSTALL WILL FAIL.

Paste in the following command and into the terminal and press enter:

git clone https://github.com/rdtripp/bmlt_droplet.git; cd bmlt_droplet; chmod +x ./installall.sh; ./installall.sh

Be prepared to answer the questions it asks:

Enter FQDN for Virtual Server: 
Enter password for Virtual Server:  
………………………………………………………………………………………………………………………..
………………………………………………………………………………………………………………………….
Adding a sudo user.  Do NOT use your domain name or any portion of it! 
Enter a name for a sudo user: 
Enter a password for a sudo user: 
………………………………………………………………………………………………………………………..
………………………………………………………………………………………………………………………….
Configuring tzdata
select county and press enter
select time zone and press enter
………………………………………………………………………………………………………………………..
………………………………………………………………………………………………………………………….
Select the version of Virtualmin you want to install 
Virtualmin Minimal is adequate for this application and takes less resources 
Only choose Virtualmin Full if you need the extra features and know what you are doing 
Install Virtualmin Minimal or Full? select 1 or 2 
1) Minimal 
2) Full 
#? 
………………………………………………………………………………………………………………………..
………………………………………………………………………………………………………………………….
Install certificate from Letsencrypt? select 1 or 2 
1) Yes 
2) No 
#? 
………………………………………………………………………………………………………………………..
…………………………………………………………………………………………………………………………

Install WordPress? select 1 or 2 
1) Yes 
2) No 
#? 

Enter Admin User for WordPress:
Enter WordPress Admin User Password:
Enter WordPress Default Site Name:
………………………………………………………………………………………………………………………..
………………………………………………………………………………………………………………………….


Enable WordPress Multisite? Select 1 or 2 
1) Yes 
2) No 
#? 
………………………………………………………………………………………………………………………..
………………………………………………………………………………………………………………………….

Install a BMLT Root Server? Select 1 or 2 
1) Yes 
2) No 
#? 
………………………………………………………………………………………………………………………..………………………………………………………………………………………………………………………….
Enter your Google Maps API key:
………………………………………………………………………………………………………………………..………………………………………………………………………………………………………………………….
Install Yap?  Select 1 or 2 
1) Yes 
2) No 
#? 
………………………………………………………………………………………………………………………..………………………………………………………………………………………………………………………….
Configuring YAP 
Enter Phone Greeting (title in config.php):
Enter your BMLT root server:
Enter your Google Maps API key:
Enter your twilio account sid:
Enter your twilio Auth Token:
Enter your BMLT root server user name:
Enter your BMLT root server password:

………………………………………………………………………………………………………………………..………………………………………………………………………………………………………………………….

The virtual Server https://<your droplet FQDN> has user  with password 


The sudo user is <sudo user selected at setup>with the password <sudo password selected at setup> 


To access virtualmin go to https://<your droplet FQDN>:10000 and log in as root or <your sudo user> 


To access WordPress Admin go to https://<your virtual server FQDN>/wp-admin/ and log in using user <admin user selected at setup> and password <password selected at setup> 


Checking Yap configuration and initializing database 

{"status":true,"message":"Ready To Yap!","version":"3.1.0"} 

To access Yap Admin Console go to https://<your virtual server FQDN>/yap/admin/ 


Make note of the following info to set up the BMLT root server: 

BMLT database: bmlt_xxxx
BMLT database user: xxxx
BMLT database password:  <this will be the same as the virtual server user password>
Google Maps API:  xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx 

To set up your BMLT Root Server go to https://<virtual server FQDN>/main_server/ 


A reboot is required 
Do you want to reboot now? (y or n) n  
