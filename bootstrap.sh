#!/bin/bash

# Setup symlinks for the config files
for file in $(find home -type f); do
	filepath=$(echo $file | cut -f 2- -d /)
	dirpath=~/$(dirname $filepath)

	if [ ! -e $dirpath ]; then
		mkdir $dirpath
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
