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

# Add tab completion for many Bash commands
if which brew &> /dev/null && [ -r "$(brew --prefix)/etc/profile.d/bash_completion.sh" ]; then
	# Ensure existing Homebrew v1 completions continue to work
	export BASH_COMPLETION_COMPAT_DIR="$(brew --prefix)/etc/bash_completion.d"
	source "$(brew --prefix)/etc/profile.d/bash_completion.sh"
elif [ -f /etc/bash_completion ]; then
	source /etc/bash_completion
fi
