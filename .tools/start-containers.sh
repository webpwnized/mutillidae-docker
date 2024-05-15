#!/bin/bash
# Script must be run from the mutillidae-docker directory 

echo "";
echo "Starting containers";
docker-compose -f docker-compose.yml up -d;

echo "";
echo "Waiting for database to start";
sleep 10;

echo "";
echo "Requesting Mutillidae database be built";
curl http://mutillidae.localhost/set-up-database.php;

echo "";
echo "Uploading Mutillidae LDIF file to LDAP directory server";
CURRENT_DIRECTORY=$(pwd);
ldapadd -c -x -D "cn=admin,dc=mutillidae,dc=localhost" -w mutillidae -H ldap:// -f $CURRENT_DIRECTORY/ldap/ldif/mutillidae.ldif;

# Wait for the user to press Enter key
read -p "Press Enter to continue or <CTRL>-C to stop" </dev/tty

echo "";
echo "Clearing the screen";
clear;
