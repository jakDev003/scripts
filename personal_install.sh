#!/bin/bash

echo "-----------------------------------------------------------"
echo "Setting up"
echo "-----------------------------------------------------------"
sudo apt-get update && sudo apt-get upgrade -y
sudo apt-get install git curl wget -y
touch .gitconfig
echo "[user]" >> .gitconfig
echo "    email = linkspace003@fastmail.com" >> .gitconfig
echo "    name = Josh K" >> .gitconfig
echo "[core]" >> .gitconfig
echo "    autocrlf = input" >> .gitconfig

echo "-----------------------------------------------------------"
echo "Installing Programs"
echo "-----------------------------------------------------------"
sudo sh ./Personal_Scripts/install_dotnet8.sh
sudo sh ./Personal_Scripts/install_fastfetch.sh
sudo sh ./Personal_Scripts/install_nvm.sh
sudo sh ./Personal_Scripts/install_ripgrep.sh
sudo sh ./Personal_Scripts/install_starship.sh
sudo sh ./Personal_Scripts/install_vim.sh

echo "-----------------------------------------------------------"
echo "Cleaning up"
echo "-----------------------------------------------------------"
sudo apt-get autoremove -y
