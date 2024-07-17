#!/bin/bash

for dir in ~/code/*
do
    dir=${dir%*/} # remove the trailing slash
    echo "${dir##*/}"
    cd ${dir}
    pwd
    git reset --hard
    git checkout master
done
