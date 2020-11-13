#!/bin/bash

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
