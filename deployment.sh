#!/usr/bin/env bash
echo "### Updating base system"
aptitude update
aptitude full-upgrade

echo "### Installing Apache, PHP, git and generic PHP modules"
aptitude install apache2 libapache2-mod-php5 git php5-dev php5-gd php-pear php5-mysql php5-pgsql php5-sqlite php5-interbase php5-sybase php5-odbc libmdbodbc1 unzip make libaio1 bc screen htop git subversion sqlite sqlite3

echo "### Configuring Apache and PHP"
rm /var/www/index.html
mkdir /var/www/test
chmod 777 /var/www/test
a2enmod auth_basic auth_digest
sed -i 's/AllowOverride None/AllowOverride AuthConfig/' /etc/apache2/sites-enabled/*
sed -i 's/magic_quotes_gpc = On/magic_quotes_gpc = Off/g' /etc/php5/*/php.ini
sed -i 's/extension=suhosin.so/;extension=suhosin.so/g' /etc/php5/conf.d/suhosin.ini
update-rc.d apache2 defaults

echo "### Restarting Apache web server"
service apache2 restart

echo "### Downloading sqlmap test environment to /var/www"
cd /var/www
git clone https://github.com/DeadPackets/testenv.git sqlmap

echo "### Installing MySQL database management system (clients, server, libraries)"
echo "### NOTE: when asked for a password, type 'testpass'"
aptitude install mysql-client mysql-server libmysqlclient-dev libmysqld-dev
update-rc.d mysql defaults

echo "### Initializing MySQL test database and table"
echo "### NOTE: when asked for a password, type 'testpass'"
mysql -u root -p mysql < /var/www/sqlmap/schema/mysql.sql
sed -i 's/bind-address            = 127.0.0.1/bind-address            = 0.0.0.0/g' /etc/mysql/my.cnf
service mysql restart

echo "### Restarting Apache web server (following installation and setup of PHP modules)"
service apache2 restart

echo "### Checking out sqlmap source code into /opt/sqlmap"
git clone https://github.com/sqlmapproject/sqlmap.git /opt/sqlmap

echo "### Installing sqlmap dependencies"
aptitude install python-setuptools python-dev python-kinterbasdb python-pymssql python-psycopg2 python-pyodbc python-pymssql python-sqlite python-impacket python-jpype
git clone https://github.com/petehunt/PyMySQL /tmp/PyMySQL
cd /tmp/PyMySQL
python setup.py install
cd /tmp
wget http://downloads.sourceforge.net/project/cx-oracle/5.1.2/cx_Oracle-5.1.2.tar.gz
tar xvfz cx_Oracle-5.1.2.tar.gz
cd cx_Oracle-5.1.2
python setup.py install
cd /tmp
git clone https://code.google.com/p/ibm-db ibm-db
cd ibm-db/IBM_DB/ibm_db
python setup.py install
cd /tmp
svn checkout http://python-ntlm.googlecode.com/svn/trunk/ python-ntlm
cd python-ntlm/python26
python setup.py install
easy_install jaydebeapi

echo "### Clean up installation"
aptitude clean

echo "### Patching ~/.bashrc"
cat << EOF >> ~/.bashrc

alias mysqlconn='mysql -u root -p testdb'

alias mysqlconnsqlmap='python /opt/sqlmap/sqlmap.py -d mysql://root:testpass@127.0.0.1:3306/testdb -b --sql-shell -v 6'

alias upgradeall='aptitude update && aptitude -y full-upgrade && aptitude clean && sync'
EOF

source ~/.bashrc

