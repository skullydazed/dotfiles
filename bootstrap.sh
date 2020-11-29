#!/bin/bash

# Make sure our profile will get loaded
if [ -f ~/.bash_profile ]; then
	mv ~/.bash_profile ~/.bash_profile.$(date +%Y%m%d-%H%M%S)
fi

# Disable the fucking broken ass shell session shit
touch ~/.bash_sessions_disable

# Setup symlinks for the config files
for file in $(find home -type f); do
	filepath=$(echo $file | cut -f 2- -d /)
	dirpath=~/$(dirname $filepath)

	if [ ! -e $dirpath ]; then
		mkdir -p $dirpath
	elif [ ! -d $dirpath ]; then
		echo "*** Directory $dirpath already exists and isn't a directory! Skipping ${filepath}."
		continue
	fi

	if [ -L ~/$filepath ]; then
		continue
	elif [ -f ~/$filepath ]; then
		mv ~/$filepath ~/$filepath.$(date +%Y%m%d-%H%M%S)
	elif [ -e ~/$filepath ]; then
		echo "*** ~/$filepath is not a regular file or a symbolic link!"
		continue
	fi

	ln -s $PWD/$file ~/$filepath
done

# Install our requirements
if ! which python3; then
	echo 'Warning: No python3 on this system!'
fi

python3 -m pip install -U --user -r requirements.txt &> /dev/null
