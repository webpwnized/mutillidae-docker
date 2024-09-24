# OWASP Mutillidae II

## Project Announcements

* **Twitter**: [https://twitter.com/webpwnized](https://twitter.com/webpwnized)

## Tutorials

* **YouTube**: [https://www.youtube.com/user/webpwnized](https://www.youtube.com/user/webpwnized)

## Installation on Docker

The following video tutorials explain how to bring up Mutillidae on a set of 5 containers running Apache/PHP, MySQL, OpenLDAP, PHPMyAdmin, and PHPLDAPAdmin:
* **YouTube**: [How to Install Docker on Ubuntu](https://www.youtube.com/watch?v=Y_2JVREtDFk)
* **YouTube**: [How to Run Mutillidae on Docker](https://www.youtube.com/watch?v=9RH4l8ff-yg)

## TLDR

```bash
git clone https://github.com/webpwnized/mutillidae-docker.git
cd mutillidae-docker
docker compose -f .build/docker-compose.yml up --build --detach
```

Generate the database with the first link in the warning webpage.

## Important Information

The web site assumes the user will access the site using domain mutillidae.localhost. The domain can be configured in the users local hosts file.

## Instructions

There are five containers in this project. 

- **www** - Apache, PHP, Mutillidae source code. The web site is exposed on ports 80,443, and 8080.
- **database** - The MySQL database. The database is not exposed externally, but feel free to modify the docker file to expose the database.
- **database_admin** - The PHPMyAdmin console. The console is exposed on port 81.
- **ldap** - The OpenLDAP directory. The directory is exposed on port 389 to allow import of the mutillidae.ldif file.
- **ldap_admin** - The PHPLDAPAdmin console. The console is exposed on port 82.

The Dockerfile files in each directory contain the instructions to build each container. The docker-compose.yml file contains the instructions to set up networking for the container, create volumes, and kick off the builds specified in the Dockerfile files.

### Building the Containers

To build the containers, if necessary, and bring the containers up, run the following command.

```bash
git clone https://github.com/webpwnized/mutillidae-docker.git
cd mutillidae-docker
docker compose -f .build/docker-compose.yml up --build --detach
```
### Website URL

The web application should be running at localhost

[http://127.0.0.1/](http://127.0.0.1/)

Note: The first time the webpage is accessed, a warning webpage will be displayed referencing the database cannot be found. This is the expected behaviour. Just use the link to "rebuild" the database and it will start working normally.

## TMI

### Running Services

Once the containers are running, the following services are available on localhost.

- Port 80, 8080: Mutillidae HTTP web interface
- Port 81: MySQL Admin HTTP web interface
- Port 82: LDAP Admin web interface
- Port 443: HTTPS web interface
- Port 389: LDAP interface

### Using a script to build the database

Alternatively, you can trigger the database build.

```bash
# Requesting Mutillidae database be built.
curl http://127.0.0.1/set-up-database.php;
```

### Populating the LDAP database

The LDAP database is empty upon build. Add users to the LDAP database using the following command.

```bash
# Install LDAP Utilities including ldapadd
sudo apt-get update
sudo apt-get install -y ldap-utils

# Add users to the LDAP database
ldapadd -c -x -D "cn=admin,dc=mutillidae,dc=localhost" -w mutillidae -H ldap://localhost:389 -f .build/ldap/configuration/ldif/mutillidae.ldif
```

### Using a script to test the web interface

You can test if the web site is responsive

```bash
# This should return the index.php home page content
curl http://127.0.0.1:8888/;
```
