#webpwnized/mutillidae:www

# Start with recent version of PHP with Apache 
# https://hub.docker.com/_/php?tab=tags&page=1&ordering=last_updated&name=apache
FROM php:8.1.8-apache

# Arguments with default values, but can be overidden
ARG DATABASE_HOST="database"
ARG DATABASE_USERNAME="root"
ARG DATABASE_PASSWORD="mutillidae"
ARG DATABASE_NAME="mutillidae"
ARG DATABASE_PORT="3306"

# Update software packages
RUN apt-get update

# Install git
RUN apt-get install -y git

# Copy the mutillidae project to Apache web files directory
RUN git clone https://github.com/webpwnized/mutillidae.git /var/www/mutillidae

# uninstall git
RUN apt-get remove -y git

# Remove the .htaccess file since the containers will use container network security rather than htaccess access control
RUN rm /var/www/mutillidae/.htaccess

# Change the database configuration variables in the mutillidae project, allowing the user to override using build arguments
RUN sed -i "s/define('DB_HOST', '127.0.0.1');/define('DB_HOST', '$DATABASE_HOST');/" /var/www/mutillidae/includes/database-config.inc
RUN sed -i "s/define('DB_USERNAME', 'root');/define('DB_USERNAME', '$DATABASE_USERNAME');/" /var/www/mutillidae/includes/database-config.inc
RUN sed -i "s/define('DB_PASSWORD', 'mutillidae');/define('DB_PASSWORD', '$DATABASE_PASSWORD');/" /var/www/mutillidae/includes/database-config.inc
RUN sed -i "s/define('DB_NAME', 'mutillidae');/define('DB_NAME', '$DATABASE_NAME');/" /var/www/mutillidae/includes/database-config.inc
RUN sed -i "s/define('DB_PORT', 3306);/define('DB_PORT', $DATABASE_PORT);/" /var/www/mutillidae/includes/database-config.inc

# Change the hostname of the ldap server to the docker ldap hostname
RUN sed -i 's/127.0.0.1/directory/' /var/www/mutillidae/includes/ldap-config.inc

# Copy the TLS certificate files from mutillidae into cert directories
RUN cp /var/www/mutillidae/configuration/https-certificate/mutillidae-selfsigned.crt /etc/ssl/certs/mutillidae-selfsigned.crt
RUN cp /var/www/mutillidae/configuration/https-certificate/mutillidae-selfsigned.key /etc/ssl/private/mutillidae-selfsigned.key

# Copy the Apache configuration from Mutillidae into Apache conf
RUN mkdir /etc/apache2/conf/
RUN cp /var/www/mutillidae/configuration/apache-configuration/conf/error-pages.conf /etc/apache2/conf/error-pages.conf
RUN cp /var/www/mutillidae/configuration/apache-configuration/conf/headers.conf /etc/apache2/conf/headers.conf

RUN mkdir /var/www/mutillidae/error-pages/
RUN cp /var/www/mutillidae/configuration/apache-configuration/error-pages/404.html /var/www/mutillidae/error-pages/404.html
RUN cp /var/www/mutillidae/configuration/apache-configuration/error-pages/oops.jpg /var/www/mutillidae/error-pages/oops.jpg

RUN cp /var/www/mutillidae/configuration/apache-configuration/conf-available/aliases.conf /etc/apache2/conf-available/aliases.conf

RUN cp /var/www/mutillidae/configuration/apache-configuration/sites-available/mutillidae.conf /etc/apache2/sites-available/mutillidae.conf

# Install PHP requirements used by Mutillidae II
RUN apt-get install -y libldap2-dev && docker-php-ext-install ldap
RUN docker-php-ext-install mysqli
RUN apt-get install -y libxml2-dev && docker-php-ext-install xml
RUN apt-get install -y libonig-dev && docker-php-ext-install mbstring
RUN apt-get install -y libcurl4-openssl-dev && docker-php-ext-install curl 

# Install nslookup to enable the command injection vulnerabilities
RUN apt-get install -y dnsutils

# Package for Lab #12
RUN apt-get install -y ntp

# Patch the container
RUN apt -y upgrade

# Enable Apache modules and sites
RUN a2enmod ssl
RUN a2dissite 000-default
RUN a2ensite mutillidae

# User for Lab #17
RUN useradd -M phinius -p 123456

# Open ports 80,443 in the container firewall
EXPOSE 80
EXPOSE 443
