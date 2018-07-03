#!/bin/sh

echo $1
file_path=$1
hook_directory=$2

file_name=${file_path##*/}
echo "$file_name"
hook_name=${file_name%.*}

cp -v $1 "$2/.git/hooks/$hook_name"
chmod -v +x "$2/.git/hooks/$hook_name"
