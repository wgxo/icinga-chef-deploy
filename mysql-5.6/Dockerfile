FROM mysql:5.6

RUN set -x && \
    apt-get update && \
    apt-get install -y --no-install-recommends logrotate bsdutils && \
    rm -rf /var/lib/apt/lists/* && \
    touch /docker-entrypoint-initdb.d/empty.sql

# Directory for log backups
VOLUME /opt/backups

ADD ./files/scripts/mysql-backup.sh              /opt/
ADD ./files/config/mysql_logs.cron               /etc/cron.d/
ADD ./files/config/logrotate-mybackup.conf       /etc/
ADD ./files/config/custom.cnf                    /etc/mysql/conf.d/

RUN chmod 644 /etc/cron.d/mysql_logs.cron /etc/logrotate-mybackup.conf && \
    crontab /etc/cron.d/mysql_logs.cron && \
    chmod +x /opt/mysql-backup.sh && \
    echo "[mysqladmin]\nuser=root\npassword=${MYSQL_ROOT_PASSWORD:=devdev}\n" > ~/.my.cnf

CMD cron && mysqld
