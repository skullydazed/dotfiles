# skullydazed's dotfiles

## Installation

You can install this with:

    curl https://raw.githubusercontent.com/skullydazed/dotfiles/main/install.sh | bash

It will update itself every time you login.

## Things to know about

### .note files

Put a file named .note into a directory and the contents will be displayed every time you enter that directory.

### Updating

When you login the dotfiles will be updated automatically in the background, and any missing symlinks will be added. If you change where a symlink points to the update system will not change it- this gives you a way to handle local overrides if needed.

Your .profile changes will not be picked up until the next time you login.
