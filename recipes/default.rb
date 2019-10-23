#
# Cookbook Name:: icinga-dist
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.


##############  DIRECTORIES  ##############

directory "/opt/deploy/apache/conf/modules/monitoring" do
  action :create
  recursive true
end

directory "/opt/deploy/mysql" do
  action :create
end

directory "/opt/deploy/scripts" do
  action :create
end

directory "/opt/deploy/conf" do
  action :create
end

###############  TEMPLATES  ###################

template "/opt/deploy/apache/build.sh" do
  source 'apache/build.sh.erb'
  mode 0755
end

template "/opt/deploy/apache/conf/authentication.ini" do
  source 'apache/conf/authentication.ini.erb'
end

template "/opt/deploy/apache/conf/config.ini" do
  source 'apache/conf/config.ini.erb'
end

template "/opt/deploy/apache/conf/modules/monitoring/backends.ini" do
  source 'apache/conf/modules/monitoring/backends.ini.erb'
end

template "/opt/deploy/apache/conf/modules/monitoring/commandtransports.ini" do
  source 'apache/conf/modules/monitoring/commandtransports.ini.erb'
end

template "/opt/deploy/apache/conf/modules/monitoring/config.ini" do
  source 'apache/conf/modules/monitoring/config.ini.erb'
end

template "/opt/deploy/apache/conf/resources.ini" do
  source 'apache/conf/resources.ini.erb'
end

template "/opt/deploy/apache/conf/roles.ini" do
  source 'apache/conf/roles.ini.erb'
end

template "/opt/deploy/apache/Dockerfile" do
  source 'apache/Dockerfile.erb'
end

template "/opt/deploy/apache/reload.sh" do
  source 'apache/reload.sh.erb'
  mode 0755
end

template "/opt/deploy/apache/startup.sh" do
  source 'apache/startup.sh.erb'
  mode 0755
end

template "/opt/deploy/mysql/build.sh" do
  source 'mysql/build.sh.erb'
  mode 0755
end

template "/opt/deploy/mysql/Dockerfile" do
  source 'mysql/Dockerfile.erb'
end

template "/opt/deploy/mysql/icinga2.sql" do
  source 'mysql/icinga2.sql.erb'
end

template "/opt/deploy/mysql/icingaweb2.sql" do
  source 'mysql/icingaweb2.sql.erb'
end

template "/opt/deploy/mysql/mysqld_logs.cnf" do
  source 'mysql/mysqld_logs.cnf.erb'
end

template "/opt/deploy/mysql/reload.sh" do
  source 'mysql/reload.sh.erb'
  mode 0755
end

template "/opt/deploy/mysql/startup.sh" do
  source 'mysql/startup.sh.erb'
  mode 0755
end

template "/opt/deploy/post-install.sh" do
  source 'post-install.sh.erb'
  mode 0755
end

template "/opt/deploy/scripts/19daily" do
  source 'scripts/19daily.erb'
end

template "/opt/deploy/scripts/apache-backup.sh" do
  source 'scripts/apache-backup.sh.erb'
  mode 0755
end

template "/opt/deploy/scripts/apache-reload.sh" do
  source 'scripts/apache-reload.sh.erb'
  mode 0755
end

template "/opt/deploy/scripts/logrotate-s3backup.conf" do
  source 'scripts/logrotate-s3backup.conf.erb'
end

template "/opt/deploy/scripts/mysql-backup.sh" do
  source 'scripts/mysql-backup.sh.erb'
  mode 0755
end

template "/opt/deploy/scripts/mysql-reload.sh" do
  source 'scripts/mysql-reload.sh.erb'
  mode 0755
end

template "/opt/deploy/scripts/s3cmd.conf" do
  source 'scripts/s3cmd.conf.erb'
end

template "/opt/deploy/scripts/start-apache.sh" do
  source 'scripts/start-apache.sh.erb'
  mode 0755
end

template "/opt/deploy/scripts/start-mysql.sh" do
  source 'scripts/start-mysql.sh.erb'
  mode 0755
end

template "/opt/deploy/scripts/stop-apache.sh" do
  source 'scripts/stop-apache.sh.erb'
  mode 0755
end

template "/opt/deploy/scripts/stop-mysql.sh" do
  source 'scripts/stop-mysql.sh.erb'
  mode 0755
end

template "/opt/deploy/icinga-script.sh" do
  source 'icinga-script.sh.erb'
  mode 0755
end

template "/opt/deploy/conf/my.cnf" do
  source 'conf/my.cnf.erb'
end

template "/opt/deploy/conf/hosts.conf" do
  source 'conf/hosts.conf.erb'
end

template "/opt/deploy/conf/templates_extra.conf" do
  source 'conf/templates_extra.conf.erb'
end

template "/opt/deploy/conf/services_extra.conf" do
  source 'conf/services_extra.conf.erb'
end

############ EXECUTE SCRIPTS #################

 ruby_block 'live stdout' do
   block do
     require 'mixlib/shellout'
     code = <<-EOH
       cd /opt/deploy
       bash icinga-script.sh

       cd /opt/deploy/mysql
       bash build.sh

       cd /opt/deploy/apache
       bash build.sh

       cd /opt/deploy
       bash post-install.sh
     EOH
     cmd = Mixlib::ShellOut.new(code)
     cmd.live_stdout = $stdout
     cmd.run_command

   end
 end
