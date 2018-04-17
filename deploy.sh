#!/bin/bash

if [ $# -eq 0 ]; then
	echo 'Usage: ./package.sh version'
	exit 1
fi

tag_name=$1

git push --delete origin $tag_name
git tag -d $tag_name

git tag -a $tag_name -m"-"
git push origin $tag_name
