#webpwnized/mutillidae:www

# Start with recent version of PHP with Apache 
# https://hub.docker.com/_/php?tab=tags&page=1&ordering=last_updated&name=apache
FROM php:8.1.9-apache

# Arguments with default values, but can be overidden
ARG DATABASE_HOST="database"
ARG DATABASE_USERNAME="root"
ARG DATABASE_PASSWORD="mutillidae"
ARG DATABASE_NAME="mutillidae"
ARG DATABASE_PORT="3306"


# ######################### #
# Install software packages #
# ######################### #

# Update software packages
# Install PHP requirements used by Mutillidae II: php-xml, php-mbstring, php-curl, php-mysql, php-ldap
# Install nslookup to enable the command injection vulnerabilities
# Install ntp package for Lab #12
# Install ping package for Lab #13
# Install git
RUN apt-get update && \
    apt-get install -y libldap2-dev && docker-php-ext-install ldap && \
    apt-get install -y libxml2-dev && docker-php-ext-install xml && \
    apt-get install -y libonig-dev && docker-php-ext-install mbstring && \
    apt-get install -y libcurl4-openssl-dev && docker-php-ext-install curl && \ 
    docker-php-ext-install mysqli && \
    apt-get install -y dnsutils ntp iputils-ping git
    
# Copy the mutillidae project to Apache web files directory
RUN git clone https://github.com/webpwnized/mutillidae.git /var/www/mutillidae

# uninstall git
# Patch the container
RUN apt-get remove -y git && \
    apt -y upgrade


# #################################### #
# Configure the PHP application server #
# #################################### #
# Use development version of the PHP ini file
# Make PHP vulnerable to RFI again
# Ensure the PHP server banner shows in the HTTP response
RUN cp /usr/local/etc/php/php.ini-development /usr/local/etc/php/php.ini && \
    sed -i 's/allow_url_include = Off/allow_url_include = On/g' /usr/local/etc/php/php.ini && \
    sed -i 's/allow_url_fopen = Off/allow_url_fopen = On/g' /usr/local/etc/php/php.ini && \
    sed -i 's/expose_php = Off/expose_php = On/g' /usr/local/etc/php/php.ini


# ######################### #
# Configure the application #
# ######################### #

# Remove the .htaccess file since the containers will use container network security rather than htaccess access control
# Change the database configuration variables in the mutillidae project, allowing the user to override using build arguments
RUN rm /var/www/mutillidae/.htaccess && \
    sed -i "s/define('DB_HOST', '127.0.0.1');/define('DB_HOST', '$DATABASE_HOST');/" /var/www/mutillidae/includes/database-config.inc && \
    sed -i "s/define('DB_USERNAME', 'root');/define('DB_USERNAME', '$DATABASE_USERNAME');/" /var/www/mutillidae/includes/database-config.inc && \
    sed -i "s/define('DB_PASSWORD', 'mutillidae');/define('DB_PASSWORD', '$DATABASE_PASSWORD');/" /var/www/mutillidae/includes/database-config.inc && \
    sed -i "s/define('DB_NAME', 'mutillidae');/define('DB_NAME', '$DATABASE_NAME');/" /var/www/mutillidae/includes/database-config.inc && \
    sed -i "s/define('DB_PORT', 3306);/define('DB_PORT', $DATABASE_PORT);/" /var/www/mutillidae/includes/database-config.inc

# ######################## #
# Configure the web server #
# ######################## #

# Change the hostname of the ldap server to the docker ldap hostname
RUN sed -i 's/127.0.0.1/directory/' /var/www/mutillidae/includes/ldap-config.inc

# Copy the TLS certificate files from mutillidae into cert directories
RUN cp /var/www/mutillidae/configuration/https-certificate/mutillidae-selfsigned.crt /etc/ssl/certs/mutillidae-selfsigned.crt  && \
    cp /var/www/mutillidae/configuration/https-certificate/mutillidae-selfsigned.key /etc/ssl/private/mutillidae-selfsigned.key

# Copy the host entries into the host file
# Copy the Apache configuration from Mutillidae into Apache conf
# Change the localhost references to listen on external network interfaces
# Create the default Apache page
RUN mkdir /etc/apache2/conf/ && \
    cp /var/www/mutillidae/configuration/apache-configuration/conf/error-pages.conf /etc/apache2/conf/error-pages.conf && \
    cp /var/www/mutillidae/configuration/apache-configuration/conf/headers.conf /etc/apache2/conf/headers.conf && \
    mkdir /etc/apache2/error-pages/ && \
    cp /var/www/mutillidae/configuration/apache-configuration/error-pages/404.html /etc/apache2/error-pages/404.html && \
    cp /var/www/mutillidae/configuration/apache-configuration/error-pages/oops.jpg /etc/apache2/error-pages/oops.jpg && \
    cp /var/www/mutillidae/configuration/apache-configuration/conf-available/aliases.conf /etc/apache2/conf-available/aliases.conf && \
#    cp /var/www/mutillidae/configuration/apache-configuration/sites-available/000-default.conf /etc/apache2/sites-available/000-default.conf && \
    cp /var/www/mutillidae/configuration/apache-configuration/sites-available/mutillidae.conf /etc/apache2/sites-available/mutillidae.conf && \
#    sed -i 's/127.0.0.1/0.0.0.0/' /etc/apache2/sites-available/000-default.conf && \
    sed -i 's/127.0.0.1/0.0.0.0/' /etc/apache2/sites-available/mutillidae.conf # && \
#    echo "<html><head><title>It works</title></head><body><h1>It works</h1></body></html>" > /var/www/html/index.html

# Enable Apache TLS modules, the default site, and the mutillidae site
RUN a2enmod ssl && \
    # a2ensite 000-default && \
    a2ensite mutillidae

# Add the user for Lab #17
RUN useradd -M phinius -p 123456

# Open ports 80,443 in the container firewall
EXPOSE 80
EXPOSE 443
