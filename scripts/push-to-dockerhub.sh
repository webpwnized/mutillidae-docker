#!/bin/bash

# Check if required arguments were passed
if (( $# != 3 )); then
    printf "%b" "Usage: $0 <version> <annotation> <force rebuild>\n" >&2;
    echo "version - Current version of the project" >&2;
    echo "annotation - Short description of the change" >&2;
    echo "force rebuild - TRUE or FALSE" >&2;
    exit 1;
fi;

# declare an array of the tags
declare -a tags=("database" "database_admin" "www" "ldap" "ldap_admin");

# Declare variables
VERSION=$1;
ANNOTATION=$2;
FORCE_REBUILD=$3;
REGISTRY="docker.io";
ACCOUNT="webpwnized";
REPOSITORY="mutillidae";
NO_CACHE="";
CURRENT_DIR="$(pwd)";
PARENT_DIR="..";
FORCE_REBUILD=$(echo $FORCE_REBUILD | tr [:lower:] [:upper:]);

if [ $FORCE_REBUILD == "TRUE" ]; then
	NO_CACHE="--no-cache";
fi;

echo "Version: $VERSON";
echo "Annotation: $ANNOTATION";
echo "Force Rebuild: $FORCE_REBUILD";
echo "No cache option: $NO_CACHE";
echo "";

echo "Updating the project version file";
echo $VERSION > $PARENT_DIR/version;

$CURRENT_DIR/git.sh "$VERSION" "$ANNOTATION";

# Login to DockerHub
echo "Logging into DockerHub";
docker login;

# Push the containers to DockerHub
echo "Pushing the containers to $REGISTRY";
for i in "${tags[@]}"; do
    #echo "Performing security scan for $REGISTRY/$ACCOUNT/$REPOSITORY:$i-$VERSION"
    #docker scan $REGISTRY/$ACCOUNT/$REPOSITORY:$i > /tmp/$REGISTRY-$ACCOUNT-$REPOSITORY-$i-$VERSION.scan 
    #echo "Scan results saved to $REGISTRY/$ACCOUNT/$REPOSITORY:$i-$VERSION"

    echo "";
    echo "Building the local $i image without the version tag";
    echo "Running command: docker build $NO_CACHE -t $ACCOUNT/$REPOSITORY:$i $i";
    docker build $NO_CACHE -t $ACCOUNT/$REPOSITORY:$i $i;

    echo "";
    echo "Creating a tag for local $i that includes the version";
    echo "Running command: docker build -t $ACCOUNT/$REPOSITORY:$i-$VERSION $i";
    docker build -t $ACCOUNT/$REPOSITORY:$i-$VERSION $i;

    echo "";
    echo "Pushing $REGISTRY/$ACCOUNT/$REPOSITORY:$i to the DockerHub repository";
    echo "Running command: docker push $REGISTRY/$ACCOUNT/$REPOSITORY:$i";
    docker push $REGISTRY/$ACCOUNT/$REPOSITORY:$i;

    echo "";
    echo "Pushing $REGISTRY/$ACCOUNT/$REPOSITORY:$i-$VERSION to the DockerHub repository";
    echo "Running command: docker push $REGISTRY/$ACCOUNT/$REPOSITORY:$i-$VERSION";
    docker push $REGISTRY/$ACCOUNT/$REPOSITORY:$i-$VERSION;
done;


