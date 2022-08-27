#!/bin/bash

if (( $# != 2 ))
then
    printf "%b" "Usage: git.sh <version> <annotation>\n" >&2
    exit 1
fi

git tag -a $1 -m "$2"
git commit -a -m "$1 $2"
git push --tag
git push
