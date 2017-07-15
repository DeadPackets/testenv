FROM ubuntu:14.04

# Updating base system
RUN apt-get update
RUN apt-get upgrade -y

# Installing Apache, PHP, git and generic PHP modules
RUN apt-get install -y apache2 libapache2-mod-php5 git php5-dev php5-gd php-pear \
                       php5-mysql \
                       unzip make libaio1 bc screen htop git \
                       subversion sqlite sqlite3 mysql-client libmysqlclient-dev \
                       netcat

# Configuring Apache and PHP
# RUN rm /var/www/index.html
RUN mkdir /var/www/test
RUN chmod 777 /var/www/test
RUN a2enmod auth_basic auth_digest
RUN php5dismod suhosin
RUN sed -i 's/AllowOverride None/AllowOverride AuthConfig/' /etc/apache2/sites-enabled/*
RUN sed -i 's/magic_quotes_gpc = On/magic_quotes_gpc = Off/g' /etc/php5/*/php.ini

# Copy sqlmap test environment to /var/www
COPY . /var/www/sqlmap/
WORKDIR /var/www/sqlmap

# Listen on port 80
EXPOSE 80

CMD ["/var/www/sqlmap/docker/run.sh"]
