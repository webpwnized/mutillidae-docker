# *OWASP Mutillidae II*

## Project Announcements

* **Twitter**: [https://twitter.com/webpwnized](https://twitter.com/webpwnized)

## Tutorials

* **YouTube**: [https://www.youtube.com/user/webpwnized](https://www.youtube.com/user/webpwnized)

## Installation on Docker

The following video tutorials explain how to bring up Mutillidae on a set of 5 containers running Apache/PHP, MySQL, OpenLDAP, PHPMyAdmin, and PHPLDAPAdmin
* **YouTube**: [How to Install Docker on Ubuntu](https://www.youtube.com/watch?v=Y_2JVREtDFk)
* **YouTube**: [How to Run Mutillidae on Docker](https://www.youtube.com/watch?v=9RH4l8ff-yg)

## TLDR

	docker-compose up -d

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

To build the containers, if neccesary, and bring the containers up, run the following command.

	docker-compose up -d
	
Once the containers are running, the following services are available on localhost.

- Port 80, 8080: Mutillidae HTTP web interface
- Port 81: MySQL Admin HTTP web interface
- Port 82: LDAP Admin web interface
- Port 443: HTTPS web interface
- Port 389: LDAP interface

