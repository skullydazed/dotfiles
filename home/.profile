# zwhite's custom .profile
PROFILE_VERSION=23

# Global settings
EDITOR=vi
PAGER=less
BASH_SILENCE_DEPRECATION_WARNING=1

alias ls='ls -F'

set +o ignoreeof
set +o noclobber
set -o vi

# Basic environment settings
PS1='\u@\h:\w\$ '
unalias which 2>/dev/null
unset PROMPT_COMMAND

# Export important variables
export BASH_SILENCE_DEPRECATION_WARNING EDITOR PAGER PS1

# Setup thefuck, if installed
if ! which thefuck 2>&1 > /dev/null; then
	eval $(thefuck --alias)
fi

# Let the user know what version we loaded
test -t 0 && echo "Loaded ${USER}'s custom .profile version ${PROFILE_VERSION}."
