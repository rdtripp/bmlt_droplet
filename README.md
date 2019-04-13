bmlt_ubuntu_virtualmin
Prerequisites:

An account with DigitalOcean https://www.digitalocean.com/

An account with twilio https://www.twilio.com/ , a phone# with them, ACCOUNT SID , & AUTH TOKEN

Google maps api key, instructions at https://bmlt.app/google-maps-api-keys-and-geolocation-issues/

A domain that you can create dns A records. You will need at mimimum a domain for the droplet such as vhost.yourdomain.com and a domain for the virtual server such as yourdomain.com or something.yourdomain.com. WWW. for the virtual server is also recommended. If you do the full virtualmin install mail. for the virtual server is also recommended.

Install Procedure:

Create a Ubuntu 18.04.2 Droplet (the $5.00/mo one, you can upgrade later as needed) named (for example) vhost.yourdomain.org
You will get a temp password and the fixed ip address emailed to you.
Edit your dns records vhost.yourdomain.org (for example) and yourdomain.org, mail.yourdomain.org (optional) www.yourdomain.org (You can use something.yourdomain.org www.something.yourdomain.org ...... etc instead of yourdomain.org if it conflicts with an exisiting site) using the ip address of the droplet.
When dns updates, log in via terminal: ssh root@vhost.yourdomain.org and change the password
power off the server: halt --poweroff
Take a snapshot so you can revert back if you need to without having to redo dns.
Power the server back up and log back in via terminal.
Paste in the following command and into the terminal and press enter:
wget https://raw.githubusercontent.com/rdtripp/bmlt_ubuntu_virtualmin/alpha/installall.sh

Virtualmin Minimal is the default Virtualmin install. If you want the full install then open the installall.sh script using nano or vim: nano ./installall.sh and edit to select the desired Virtualmin install.
.............

#Select the version of virtualmin you want to install. Make sure only the version you want to install is uncommented. #Virtualmin Minimum is everything you need unless you want a full-blown mail server with antivirus, antispam, etc.

#Installs full Virtualmin

#sh ./install.sh -f -v

#Installs Virtualmin Minimum (default)

sh ./install.sh -f -v -m

...........

Type command into terminal: sh ./installall.sh and press enter

Be prepared to answer the questions it asks:

Enter FQDN for Virtual Server: <yourdomain.org for ex>

Enter Password for Virtual Server:

Enter Admin User for WordPress:

Enter WordPress Admin User Password:

Enter WordPress Default Site Name:

Please Enter Phone Greeting: <Thanks for calling the ........we're glad you're here for ex>

Please enter your BMLT root server: <the BMLT root server for hosting your service body ex https://texasoklahomana.org/main_server/ . If you are using the root server installed in this script it would be https://yourdomain.org/main_server/ >

Please enter your Google Maps API key:

Please enter your twilio account sid:

Please enter your twilio Auth Token:

Please BMLT root server user name:

Please enter your BMLT root server password:

You will end up with (if you used vhost.yourdomain.org for the virtual host (the droplet you created) and yourdomain.org as the virtual server) :
Virtualmin login using root credentials: https://vhost.yourdomain.org:10000

yap admin at : https://yourdomain.org/yap/admin

Wordpress multisite admin login (using credentials you entered ): https://yourdomain.org/wp-admin (wordpress-satellite-plugin, bmlt-tabbed-map, bread, and crouton are preinstalled)

BMLT root server install wizard at: https://yourdomain.org/main_server/ #Note: If setting up a root server make sure to copy the setup info displayed at the completion of the install script. Make sure to Enable Semantic Administration in the install wizard so that yap, wordpress plugins, etc can communicate with your root server.

Before you can use yap you must:

Initialize the database by going to https://yourdomain.org/yap/update-advisor.php. It should tell you that you are "ready to yap"

Set up the voice portion of your twilio number as a http get and point it at https://yourdomain.org/yap/index.php

Log in to virtualmin with root credentials and set up the virtual server cert with letsencrypt

I wrote this to accomidate a service body such as a region needing to set up a Website, a full BMLT stack, and a website for each of its areas in a subdirectory format WordPress multisite install. Other service bodies can use whatever portion they need and delete the rest (after playing with it of course). Let me know if you use this and any thoughts on how it could be improved.
