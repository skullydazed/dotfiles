# Update the dotfiles
(cd ~/dotfiles; git pull 2>&1 > /dev/null && ./bootstrap.sh) &

# Load the real .profile
source ~/.profile.full
