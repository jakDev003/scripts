#!/bin/bash

for dir in /home/dev/code/*
do
    dir=${dir%*/} # remove the trailing slash
    echo "${dir##*/}"
    cd ${dir}
    pwd
    git reset --hard
    git clean -fd
    git fetch
    git pull origin master
    git checkout master
done
