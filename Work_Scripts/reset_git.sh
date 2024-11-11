#!/bin/bash

for dir in /home/dev/code/*
do
    dir=${dir%*/} # remove the trailing slash
    echo "========================================="
    echo "${dir##*/}"
    echo "========================================="
    cd ${dir}
    pwd
    git merge --abort
    git reset --hard HEAD
    git clean -fd
    git fetch
    git pull origin master
    git checkout master
    echo "========================================="
    echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"
    echo "========================================="
    echo ""
    echo ""
done
