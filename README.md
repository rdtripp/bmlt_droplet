# bmlt_ubuntu_virtualmin

I haven't had time to write complete instructions yet and probably won't have time until after RSC in Baton Rouge this weekend.

The nickel tour:

1.  Create a Ubuntu 18.04.2 Droplet (the cheapest $5.00/mo one) named (for example) vhost.yourdomain.org
2.  You will get a temp  password and the ip address emailed to you.   
3.  Point vhost.yourdomain.org (for example) and yourdomain.org, mail.yourdomain.org (optional) www.yourdomain.org (You can use something.yourdomain.org www. ...... etc instead of yourdomain.org so it doesn't take an site off line)
4.  When dns updates ssh root@vhost.yourdomain.org and change the password
5.  power off the server using:
         halt --poweroff
6.  Take a snapshot so you can revert back if you need to without having to redo dns.
7.  Power the server back up and log back in.
8.  paste in the following command and press enter:

wget https://raw.githubusercontent.com/rdtripp/bmlt_ubuntu_virtualmin/master/installall.sh; sh ./installall.sh

9. Answer the questions it asks. --  
FQDN:  yourdomain.org (for example)
virtual server password: 
wordpress admin user:
wordpress admin password:
wordpress default site name:

In the yap portion of the install answer the questions.

title (Greeting)= 
bmlt_root_server = 
google_maps_api_key =
twilio_account_sid = 
twilio_auth_token = 
bmlt_username = 
bmlt_password = The database info will be generated for you

10.  You will end up with (if you used vhost.yourdomain.org for the virtual host (the droplet you created) and yourdomain.org as the virtual server) :

1.Virtualmin login using root credentials:  https://vhost.yourdomain.org:10000

2. yap admin at :  https://yourdomain.org/yap/admin

3. Wordpress multisite admin login (using credentials you entered ):
https://yourdomain.org/wordpress/wp-admin  (wordpress-satellite-plugin, bmlt-tabbed-map, bread, and crouton are preinstalled)

4.  BMLT root server install wizard at:  https://yourdomain.org/main_server/  #Note: If setting up a root server make sure to copy the database info displayed at the completion of the install script.

Before you can use yap:
1. initialize the database by going to https://yourdomain.org/yap/update-advisor.php.  It should tell you that you are "ready to yap"
2.  Set up the voice portion of your twilio number as a http get and point it at https://yourdomain.org/yap/index.php
3.  Log in to virtualmin with root credentials and set up the virtual server cert with letsencrypt

I wrote this for a Region needing to set up a Website, a full BMLT stack, and a site for each area in a subdirectory.  You could delete the BMLT root server if you don't need it (after playing with it of course) or not.  The multisite feature is handy for generating different variations of meeting lists or lists for different service bodies event if you ndon't need it for other service bodies websites.

