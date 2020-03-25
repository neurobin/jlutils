#!/bin/bash

BASEDIR=$(dirname "$BASH_SOURCE")

sudo apt update
sudo apt upgrade

pack_install(){
	for pack in $@; do
		if sudo apt install -y $pack; then
			echo "=== Successfully installed: $pack"
		else
			echo "!!! Failed to install: $pack" >&2
		fi
	done
}

pack_purge(){
	for pack in $@; do
		if sudo apt purge -y $pack; then
			echo "=== Successfully purged: $pack"
		else
			echo "!!! Failed to purge: $pack" >&2
		fi
	done
}

#install some packages
ipacks=(build-essential geany gedit gparted qalculate qbittorrent git tlp gnome-disk-utility artha gdebi synaptic cryptsetup virtualbox gespeaker vlc gnome-system-monitor gimp wvdial xterm zsh ksh expect hardinfo inxi openssl eog file-roller libreoffice wget tar gzip lzip thunderbird evince zlib1g-dev libbz2-dev libssl-dev libreadline-dev libncurses5-dev libsqlite3-dev libgdbm-dev libdb-dev libexpat-dev libpcap-dev liblzma-dev libpcre3-dev tk-dev msr-tools)

pack_install ${ipacks[@]}


#completely remove some packages
rpacks=(transmission-gtk parole engrampa abiword)

pack_purge ${rpacks[@]}


#Google Chrome
#wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
#sudo sh -c 'echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list'
#pack_install google-chrome-stable

#unetbootin
sudo add-apt-repository ppa:gezakovacs/ppa -y
pack_install unetbootin

#smplayer
sudo add-apt-repository ppa:rvm/smplayer -y
pack_install smplayer

#rnm, shc, oraji etc.
sudo add-apt-repository ppa:neurobin/ppa -y
pack_install rnm shc oraji tartos

#xfce4-goodies
pack_install xfce4-goodies

#lampi
wget https://raw.githubusercontent.com/neurobin/lampi/release/lampi -O lampi
chmod +x lampi
sudo mv lampi /usr/bin/

#jssh
wget https://raw.githubusercontent.com/neurobin/jssh/master/jssh -O jssh
chmod +x jssh
sudo mv jssh /usr/bin/

#JLIVECD
tmpd=$(mktemp -d)
cd "$tmpd"
wget https://github.com/neurobin/JLIVECD/archive/release.tar.gz -O - | tar zxf -
cd JLIVECD-release
chmod +x install.sh
sudo ./install.sh
cd "$BASEDIR"

