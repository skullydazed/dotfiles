#!/bin/bash

# Make sure we start from the user's home directory
cd ~

# Fetch our dotfiles
if ! [ -d ~/dotfiles ]; then
	git -C ~ clone https://github.com/skullydazed/dotfiles.git || exit
else
	(cd ~/dotfiles && git pull --ff-only) || exit
fi

cd ~/dotfiles

# Setup symlinks for the config files
for file in $(find home -type f); do
	filepath=$(echo $file | cut -f 2- -d /)

	if [ -f ~/$filepath ]; then
		mv ~/$filepath ~/$filepath.$(date +%Y%m%d-%H%M%S)
	elif [ -e ~/$filepath -a ! -L ~/$filepath ]; then
		echo "*** ~/$filepath is not a regular file or a symbolic link!"
		continue
	elif [ -L ~/$filepath ]; then
		continue
	fi
		
	ln -s $PWD/$file ~/$filepath
done

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
