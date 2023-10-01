#!/bin/bash

if (( $# != 2 ))
then
    printf "%b" "Usage: git.sh <version> <annotation>\n" >&2
    exit 1
fi

VERSION=$1
ANNOTATION=$2

echo "Creating tag $VERSION with annotation \"$ANNOTATION\""
git tag -a $VERSION -m "$ANNOTATION"

echo "Commiting version $VERSION to local branch"
git commit -a -m "$VERSION $ANNOTATION"

echo "Pushing tag $VERSION"
git push --tag

echo "Pushing version $VERSION to upstream"
git push

