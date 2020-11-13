# zwhite's custom .profile
PROFILE_VERSION=25

# Global settings
EDITOR=vi
PAGER=less
BASH_SILENCE_DEPRECATION_WARNING=1

# Useful aliases
alias ls='ls -F'
unalias which 2>/dev/null

# Settings I like
unset PROMPT_COMMAND
set +o ignoreeof
set +o noclobber
set -o vi

# Colors
PS1_BLACK='\['$(tput setaf 0)'\]'
PS1_RED='\['$(tput setaf 1)'\]'
PS1_GREEN='\['$(tput setaf 2)'\]'
PS1_YELLOW='\['$(tput setaf 3)'\]'
PS1_BLUE='\['$(tput setaf 4)'\]'
PS1_MAGENTA='\['$(tput setaf 5)'\]'
PS1_CYAN='\['$(tput setaf 6)'\]'
PS1_GREY='\['$(tput setaf 7)'\]'
PS1_BGREY='\['$(tput setaf 8)'\]'
PS1_BRED='\['$(tput setaf 9)'\]'
PS1_BGREEN='\['$(tput setaf 10)'\]'
PS1_BYELLOW='\['$(tput setaf 11)'\]'
PS1_BBLUE='\['$(tput setaf 12)'\]'
PS1_BMAGENTA='\['$(tput setaf 13)'\]'
PS1_BCYAN='\['$(tput setaf 14)'\]'
PS1_BWHITE='\['$(tput setaf 15)'\]'
PS1_BRIGHT='\['$(tput bold)'\]'
PS1_NORMAL='\['$(tput sgr0)'\]'
PS1_BLINK='\['$(tput blink)'\]'
PS1_REVERSE='\['$(tput smso)'\]'
PS1_UNDERLINE='\['$(tput smul)'\]'

# Useful functions
function update_dotfiles() {
	(cd ~/dotfiles; git pull 2>&1 > /dev/null && ./bootstrap.sh)
}

function parse_git_dirty {
	status=`git status 2>&1 | tee`
	dirty=0

        if echo -n "${status}" | grep "new file:" &> /dev/null; then
		echo -n " (new)"
	fi

        if echo -n "${status}" | grep "renamed:" &> /dev/null; then
		dirty=1
	fi

        if echo -n "${status}" | grep "deleted:" &> /dev/null; then
		dirty=1
	fi

        if echo -n "${status}" | grep "modified:" &> /dev/null; then
		dirty=1
	fi

        if [ $dirty -eq 1 ]; then
		echo -n " (dirty)"
	fi

        if echo -n "${status}" | grep "Untracked files:" &> /dev/null; then
		echo -n " (untracked)"
	fi

        if echo -n "${status}" | grep "Changes not staged for commit" &> /dev/null; then
		echo -n " (not_staged)"
	fi

        if echo -n "${status}" | grep "Your branch is ahead of" &> /dev/null; then
		echo -n " (can_push)"
	fi

        if echo -n "${status}" | grep "Your branch is behind" &> /dev/null; then
		echo -n " (can_pull)"
	fi
}

function prompt_cmd() {
	# This gets run before the prompt is displayed so we can rewrite the prompt.
	# Unfortunately bash requires escaping the escape codes in a way that makes this necessary.

	## Colorize the return code
	RETVAL=$?
	if [ $RETVAL -eq 0 ]; then
		RET_COLOR=$PS1_GREEN
	else
		RET_COLOR=$PS1_RED
	fi

	## Determine if we're on a git clone
	BRANCH=`git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'`

	## Set our prompt
	# Line 0
	# Start by returning colors to normal in case of an errant last program
	PS1=${PS1_NORMAL}'\n'

	# Check for a note in this directory, and display it if it's there.
	if [ -e .note ]; then
		PS1+=${PS1_YELLOW}'dirnote: '$(< .note)${PS1_NORMAL}'\n'
	fi

	# Line 1
	# Add the current date/time
	PS1+=${PS1_CYAN}$(date "+%Y-%m-%d %H:%M:%S %Z")${PS1_NORMAL}

	# If we're in a git clone display some relevant info about that clone
	if [ -n "$BRANCH" ]; then
		PS1+=' git['${PS1_BLUE}${BRANCH}${PS1_NORMAL}']'
		status=$(parse_git_dirty)
		if [ -n "$status" ]; then
			PS1+="${PS1_MAGENTA}$status${PS1_NORMAL}"
		fi
	fi

	# Line 2
	PS1+='\n'${PS1_GREEN}'\u@\h'${PS1_NORMAL}':'${PS1_BLUE}'\w'${PS1_NORMAL}':'${RET_COLOR}'$?'${PS1_NORMAL}'\$ '
}

# Basic environment settings
PROMPT_COMMAND=prompt_cmd

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

# Update ourselves
update_dotfiles
