mkdir /home/student/data-review


# add to inventory
[webserver]
serverb.lab.example.com

mkdir /home/student/data-review/files
The files subdirectory contains:
• A httpd.conf configuration file for the Apache web service for basic authentication
• A .htaccess file, used to control access to the web server's document root directory
• A htpasswd file containing credentials for permitted users