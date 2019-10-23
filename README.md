# Chef recipe for Apache+MySQL with monitoring using Icinga

The following instructions detail a step by step process of creating a server monitoring solution using Icinga.

## Description

This solution implements the following infrastructure:

- Downloads, installs and configures the Icinga software on a Linux server (Ubuntu)
- Ensures availability of services
- Installs Apache Web Server and MySQL Database on different Docker containers
- Collects logs from Apache and MySQL dynamically through a Bash script
- Uploads logs automatically to Amazon S3 at 7pm daily
- Takes proper backups in an optimal fashion and sends them to Amazon S3 bucket as well
- Uses a Chef recipe to automate the process

# Deployment Manual

## Installation and configuration of servers and services

The whole system has been prepared and packaged as a Chef Cookbook with a single recipe.

To deploy it, install the chefdk package in the deployment server:

_wget -c https://packages.chef.io/files/stable/chefdk/2.3.4/ubuntu/16.04/chefdk\_2.3.4-1\_amd64.deb_
_dpkg –i chefdk\_2.3.4-1\_amd64.deb_

Install the chef-client package in each node where Icinga is going to be deployed:

_wget –c https://packages.chef.io/files/stable/chef/13.6.0/ubuntu/16.04/chef\_13.6.0-1\_amd64.deb_
_dpkg -i chef\_13.6.0-1\_amd64.deb_

### Prerequisites:

The chef-client command needs to be able to connect using SSH and public key authentication to the chef server. For more information, see:

[https://www.digitalocean.com/community/tutorials/how-to-set-up-ssh-keys--2](https://www.digitalocean.com/community/tutorials/how-to-set-up-ssh-keys--2)

On the chef server, execute the following commands:

_mkdir -p /opt/deploy/chef-repo/cookbooks_
_knife configure –y --defaults -r /opt/deploy/chef-repo -s http://IP\_OF\_CHEF\_SERVER/_

Copy the icinga-dist folder to */opt/deploy/chef-repo/cookbooks* on the chef server and start it using:

`knife serve --chef-zero-host 0.0.0.0 --chef-zero-port 80`

On each node where Icinga will be deployed, execute

_knife configure client -s http://chef-server /etc/chef_
_chef-client --runlist icinga-dist_

From this point on. The process is automatic.

### Cookbook explanation

The Cookbook defines a single recipe with the following resources:

Directories:

_/opt/deploy/scripts_

Contains the start, stop, reload scripts

_/opt/deploy/mysql_

Contains the MySQL Docker container build scripts

_/opt/deploy/apache_

Contains the Apache Docker container build scripts

_/opt/deploy/apache/conf/modules/monitoring_

Contains configuration files for Icinga modules

Templates:

_/opt/deploy/apache/build.sh_
_/opt/deploy/apache/Dockerfile_
_/opt/deploy/apache/reload.sh_
_/opt/deploy/apache/startup.sh_
_/opt/deploy/apache/conf/authentication.ini_
_/opt/deploy/apache/conf/config.ini_
_/opt/deploy/apache/conf/resources.ini_
_/opt/deploy/apache/conf/roles.ini_
_/opt/deploy/apache/conf/modules/monitoring/backends.ini_
_/opt/deploy/apache/conf/modules/monitoring/commandtransports.ini_
_/opt/deploy/apache/conf/modules/monitoring/config.ini_
_/opt/deploy/mysql/build.sh_
_/opt/deploy/mysql/Dockerfile_
_/opt/deploy/mysql/icinga2.sql_
_/opt/deploy/mysql/icingaweb2.sql_
_/opt/deploy/mysql/mysqld\_safe\_syslog.cnf_
_/opt/deploy/mysql/reload.sh_
_/opt/deploy/mysql/startup.sh_
_/opt/deploy/scripts/19daily_
_/opt/deploy/scripts/apache-backup.sh_
_/opt/deploy/scripts/apache-reload.sh_
_/opt/deploy/scripts/logrotate-s3backup.conf_
_/opt/deploy/scripts/mysql-backup.sh_
_/opt/deploy/scripts/mysql-reload.sh_
_/opt/deploy/scripts/s3cmd.conf_
_/opt/deploy/scripts/start-apache.sh_
_/opt/deploy/scripts/start-mysql.sh_
_/opt/deploy/scripts/stop-apache.sh_
_/opt/deploy/scripts/stop-mysql.sh_
_/opt/deploy/icinga-script.sh_
_/opt/deploy/post-install.sh_

Installation Script:

```
cd /opt/deploy/
bash icinga-script.sh
cd /opt/deploy/mysql
bash build.sh
cd /opt/deploy/apache
bash build.sh
cd /opt/deploy/
bash post-install.sh
```

The script follows this order:

1. Prepare the Icinga server
2. Install Docker
3. Install necessary packages.
4. Build the MySQL Docker container
5. Build the Apache Docker container
6. Execute post-install tasks
7. Do cleanup
8. Start Docker containers

## POST-INSTALL STEPS

1. Login to Icinga Web by navigating to: [http://ICINGA\_NODE\_IP](http://ICINGA_NODE_IP). 
2. Enter the following credentials: icingaadmin/icingapass
3. Check that the services are up and running.
4. The Apache and MySQL logs and MySQL databases will be copied every night at 7PM to the Amazon S3 bucket. To trigger this process manually execute: _/usr/sbin/logrotate -f /etc/logrotate-s3backup.conf_
5. Enjoy!

