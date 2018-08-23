#!/bin/bash

sudo apt update
sudo apt upgrade

sudo apt install  build-essential geany gedit gparted qalculate qbittorrent git tlp

#Google Chrome
wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
sudo sh -c 'echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list'
sudo apt install google-chrome-stable

#unetbootin
sudo add-apt-repository ppa:gezakovacs/ppa -y
sudo apt install unetbootin

#smplayer
sudo add-apt-repository ppa:rvm/smplayer -y
sudo apt install smplayer

#rnm, shc, oraji
sudo add-apt-repository ppa:neurobin/ppa -y
sudo apt install rnm shc oraji

