#!/bin/bash

# Make sure we start from the user's home directory
cd ~

# Make sure git is installed
if ! git --version &> /dev/null; then
	case $(uname) in
		Linux)
			if grep -q 'ID.*debian' /etc/os-release; then
				echo 'Git not found! Installing git!'
				sudo apt update
				sudo apt install git
			else
				echo 'Unknown Linux distro! Install git!'
				exit 1
			fi
		;;
		*)
			echo 'Unknown OS! Install git!'
			exit 1
		;;
	esac

fi

# Make sure python is installed
if ! python3 --version &> /dev/null; then
	case $(uname) in
		Linux)
			if grep -q 'ID.*debian' /etc/os-release; then
				echo 'Python3 not found! Installing python3!'
				sudo apt update
				sudo apt install python3
			else
				echo 'Unknown Linux distro! Install python3!'
				exit 1
			fi
		;;
		*)
			echo 'Unknown OS! Install python3!'
			exit 1
		;;
	esac

fi

# Make sure python3-pip is installed
if ! pip3 --version &> /dev/null; then
	case $(uname) in
		Linux)
			if grep -q 'ID.*debian' /etc/os-release; then
				echo 'pip3 not found! Installing python3-pip!'
				sudo apt update
				sudo apt install python3-pip
			else
				echo 'Unknown Linux distro! Install pip3!'
				exit 1
			fi
		;;
		*)
			echo 'Unknown OS! Install pip3!'
			exit 1
		;;
	esac

fi

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
			if grep -q 'ID.*debian' /etc/os-release; then
				sudo apt update
				sudo apt install thefuck
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
