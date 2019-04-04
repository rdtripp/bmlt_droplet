# bmlt_ubuntu_virtualmin

The nickel tour:

1.  Create a Ubuntu 18.04.2 Droplet (the $5.00/mo one,  you can upgrade later as needed) named (for example) vhost.yourdomain.org
2.  You will get a temp  password and the fixed ip address emailed to you.   
3.  Edit your dns records vhost.yourdomain.org (for example) and yourdomain.org, mail.yourdomain.org (optional) www.yourdomain.org (You can use something.yourdomain.org www. ...... etc instead of yourdomain.org so if it conflicts with an exisiting site) using the ip address of the droplet.
4.  When dns updates ssh root@vhost.yourdomain.org and change the password
5.  power off the server using:
         halt --poweroff
6.  Take a snapshot so you can revert back if you need to without having to redo dns.
7.  Power the server back up and log back in.
8.  paste in the following command and into a terminal and press enter:

wget https://raw.githubusercontent.com/rdtripp/bmlt_ubuntu_virtualmin/master/installall.sh; sh ./installall.sh

9. Be prepared to answer the questions it asks:

 FQDN:  yourdomain.org (for example)

 virtual server password: 
 
 wordpress admin user:
 
 wordpress admin password:
 
 wordpress default site name:

 title (Phone Greeting):

 bmlt_root_server:

 google_maps_api_key:

 twilio_account_sid:

 twilio_auth_token:

 bmlt_username:

 bmlt_password:

10.  You will end up with (if you used vhost.yourdomain.org for the virtual host (the droplet you created) and yourdomain.org as the virtual server) :

  Virtualmin login using root credentials:  https://vhost.yourdomain.org:10000

  yap admin at :  https://yourdomain.org/yap/admin

  Wordpress multisite admin login (using credentials you entered ):
https://yourdomain.org/wordpress/wp-admin  (wordpress-satellite-plugin, bmlt-tabbed-map, bread, and crouton are preinstalled)

  BMLT root server install wizard at:  https://yourdomain.org/main_server/  #Note: If setting up a root server make sure to copy the setup info displayed at the completion of the install script.

Before you can use yap you must:

  Initialize the database by going to https://yourdomain.org/yap/update-advisor.php.  It should tell you that you are "ready to yap"
  
  Set up the voice portion of your twilio number as a http get and point it at https://yourdomain.org/yap/index.php
 
  Log in to virtualmin with root credentials and set up the virtual server cert with letsencrypt

I wrote this to accomidate a service body such as a region needing to set up a Website, a full BMLT stack, and a website for each areas in a subdirectory format WordPress multisite install.  Other service bodies can use whatever portion they need and delete the rest (after playing with it of course).  Let me know if you use this and any thoughts on how it could be improved.

