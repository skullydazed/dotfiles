#!/bin/bash

# Make sure we start from the user's home directory
cd ~

# Fetch our dotfiles
if ! [ -d ~/dotfiles ]; then
	(cd ~ && git clone https://github.com/skullydazed/dotfiles.git) || exit
else
	(cd ~/dotfiles && git pull --ff-only) || exit
fi

# Setup thefuck
if ! which thefuck 2>&1 > /dev/null; then
	case $(uname) in
		Linux)
			source /etc/os-release
			if [ $ID = debian -o $ID_LIKE = debian ]; then
				apt update
				apt install thefuck
			else
				pip3 install thefuck
			fi
			;;
		Darwin)
			brew install thefuck
			;;
		*)
			echo "Unknown OS, can't install thefuck!"
			;;
	esac
fi

# Setup dotfiles
cd ~/dotfiles
echo 'DO NOT EDIT' > .note
ln -s ../.note home
sh bootstrap.sh
