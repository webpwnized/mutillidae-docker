# Container image: webpwnized/mutillidae:www
# From project root, build with: 
#   docker build --file .build/www/Dockerfile --tag webpwnized/mutillidae:www .build/www/
#       docker build: This is the command to build a Docker image.
#       --file .build/www/Dockerfile: This specifies the path to the Dockerfile you want to use. In this case, it's .build/www/Dockerfile.
#       --tag webpwnized/mutillidae:www: This tags the resulting Docker image with a name (webpwnized/mutillidae) and a tag (www).
#       .build/www/: This is the build context. It indicates the directory to be used for the build process. The Docker daemon will send this directory's contents to the Docker engine. In this case, it represents the build context.
#
#   To enable error reporting during the build, pass the --build-arg ENABLE_ERROR_REPORTING=true argument:
#       docker build --file .build/www/Dockerfile --tag webpwnized/mutillidae:www --build-arg ENABLE_ERROR_REPORTING=true .build/www/
#           --build-arg ENABLE_ERROR_REPORTING=true: This optional argument enables error reporting during the PHP build process by setting error_reporting to E_ALL and display_errors to On.
#           By default, error reporting is disabled (ENABLE_ERROR_REPORTING=false).
#
# From project root, run with:
#   docker compose --file .build/docker-compose.yml up --build --detach
#       docker-compose: This is the Docker Compose command-line tool used for managing multi-container Docker applications.
#       --file .build/docker-compose.yml: This option (--file or -f) specifies the path to the docker-compose.yml file. In this case, it’s located at .build/docker-compose.yml.
#       up: This subcommand tells Docker Compose to create and start the containers defined in the docker-compose.yml file. If the containers do not exist, they will be created. If they already exist, they will be started.
#       --detach: This option (--detach or -d) runs the containers in the background (detached mode). When you use this option, Docker Compose will start the containers and return control to the terminal, allowing you to continue using it for other commands or tasks.


# Start with recent version of PHP with Apache 
# https://hub.docker.com/_/php?tab=tags&page=1&ordering=last_updated&name=apache
FROM php:apache

# Arguments with default values, but can be overidden
ARG DATABASE_HOST="database"
ARG DATABASE_USERNAME="root"
ARG DATABASE_PASSWORD="mutillidae"
ARG DATABASE_NAME="mutillidae"
ARG DATABASE_PORT="3306"
ARG ENABLE_ERROR_REPORTING=true	# The value can be true or false. The default is true.

# ######################### #
# Install software packages #
# ######################### #

# Update software packages
# Install PHP requirements used by Mutillidae II: php-xml, php-mbstring, php-curl, php-mysql, php-ldap
# Install nslookup to enable the command injection vulnerabilities
# Install ntp package for Lab #12
# Install ping package for Lab #13
# Install git
# Copy the mutillidae project to Apache web files directory
# uninstall git
# Patch the container
# Remove the apt-get lists after installation
# Add the user for Lab #17
RUN apt-get update && \
    apt-get install --no-install-recommends -y libldap2-dev && docker-php-ext-install ldap && \
    apt-get install --no-install-recommends -y libxml2-dev && docker-php-ext-install xml && \
    apt-get install --no-install-recommends -y libonig-dev && docker-php-ext-install mbstring && \
    apt-get install --no-install-recommends -y libcurl4-openssl-dev && docker-php-ext-install curl && \ 
    docker-php-ext-install mysqli && \
    apt-get install --no-install-recommends -y dnsutils git iputils-ping ntp && \
    cd /tmp && \
    git clone https://github.com/webpwnized/mutillidae.git mutillidae && \
    cp -r mutillidae/src /var/www/mutillidae && \
    rm -rf /tmp/mutillidae && \ 
    mkdir -p /var/www/mutillidae/data /var/www/mutillidae/passwords && \
    chown -R www-data:www-data /var/www/mutillidae/data /var/www/mutillidae/passwords && \
    chmod -R 775 /var/www/mutillidae/data /var/www/mutillidae/passwords && \
    apt-get remove --no-install-recommends -y git && \
    apt-get -y upgrade && \
    apt-get -y autoremove && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    useradd -M phinius -p 123456

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

# Conditionally enable error reporting if ENABLE_ERROR_REPORTING is true
RUN if [ "$ENABLE_ERROR_REPORTING" = "true" ]; then \
    sed -i 's/^error_reporting = .*/error_reporting = E_ALL/' /usr/local/etc/php/php.ini && \
    sed -i 's/^display_errors = .*/display_errors = On/' /usr/local/etc/php/php.ini; \
    fi

# ######################### #
# Configure the application #
# ######################### #

# Remove the .htaccess file since the containers will use container network security rather than htaccess access control
# Change the database configuration variables in the mutillidae project, allowing the user to override using build arguments
# Change the hostname of the ldap server to the docker ldap hostname
RUN rm /var/www/mutillidae/.htaccess && \
    sed -i "s/define('DB_HOST', '127.0.0.1');/define('DB_HOST', '$DATABASE_HOST');/" /var/www/mutillidae/includes/database-config.inc && \
    sed -i "s/define('DB_USERNAME', 'root');/define('DB_USERNAME', '$DATABASE_USERNAME');/" /var/www/mutillidae/includes/database-config.inc && \
    sed -i "s/define('DB_PASSWORD', 'mutillidae');/define('DB_PASSWORD', '$DATABASE_PASSWORD');/" /var/www/mutillidae/includes/database-config.inc && \
    sed -i "s/define('DB_NAME', 'mutillidae');/define('DB_NAME', '$DATABASE_NAME');/" /var/www/mutillidae/includes/database-config.inc && \
    sed -i "s/define('DB_PORT', 3306);/define('DB_PORT', $DATABASE_PORT);/" /var/www/mutillidae/includes/database-config.inc && \
    sed -i 's/127.0.0.1/directory/' /var/www/mutillidae/includes/ldap-config.inc
    
# ######################## #
# Configure the web server #
# ######################## #

# Create directories for the Apache configuration and error pages
RUN mkdir /etc/apache2/conf/ && \
    mkdir /etc/apache2/error-pages/

# Copy the TLS certificate files from mutillidae into cert directories
# Copy the host entries into the host file
# Copy the Apache configuration from Mutillidae into Apache conf
# Copy the error pages from Mutillidae into Apache error pages
# Copy the aliases configuration into Apache conf-available
# Copy the Mutillidae site configuration into Apache sites-available
COPY ./configuration/https-certificate/mutillidae-selfsigned.crt /etc/ssl/certs/mutillidae-selfsigned.crt
COPY ./configuration/https-certificate/mutillidae-selfsigned.key /etc/ssl/private/mutillidae-selfsigned.key
COPY ./configuration/apache-configuration/conf/error-pages.conf /etc/apache2/conf/error-pages.conf
COPY ./configuration/apache-configuration/conf/headers.conf /etc/apache2/conf/headers.conf
COPY ./configuration/apache-configuration/error-pages/404.html /etc/apache2/error-pages/404.html
COPY ./configuration/apache-configuration/error-pages/oops.jpg /etc/apache2/error-pages/oops.jpg
COPY ./configuration/apache-configuration/conf-available/aliases.conf /etc/apache2/conf-available/aliases.conf
COPY ./configuration/apache-configuration/sites-available/mutillidae.conf /etc/apache2/sites-available/mutillidae.conf

# Change the localhost references to listen on external network interfaces
# Unlink access log and error log so the log files can be written in the container
# Make sure access log and error log exist
# Enable Apache TLS modules
# Disable the default site because it intercepts calls to Mutillidae made by IP address
# Enable the mutillidae site
RUN sed -i 's/127.0.0.1/0.0.0.0/' /etc/apache2/sites-available/mutillidae.conf && \
    sed -i 's/127.0.0.2/0.0.0.0/' /etc/apache2/sites-available/mutillidae.conf && \
    unlink /var/log/apache2/access.log && \
    unlink /var/log/apache2/error.log && \
    touch /var/log/apache2/access.log && \
    touch /var/log/apache2/error.log && \
    a2enmod ssl && \
    a2dissite 000-default && \
    a2ensite mutillidae

# Open ports 80,443 in the container firewall
# This exposes HTTP and HTTPS
EXPOSE 80
EXPOSE 443
