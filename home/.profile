# zwhite's custom .profile
PROFILE_VERSION=24

# Pull in libraries
source ~/.bash_colors

# Global settings
EDITOR=vi
PAGER=less
BASH_SILENCE_DEPRECATION_WARNING=1

# Useful aliases
alias ls='ls -F'

# Settings I like
set +o ignoreeof
set +o noclobber
set -o vi

# Useful functions
function parse_git_branch() {
	BRANCH=`git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'`
	if [ -n "${BRANCH}" ]; then
		clr_blue "${BRANCH}"
	fi
}

function parse_git_dirty {
	status=`git status 2>&1 | tee`
	dirty=0

        if echo -n "${status}" 2> /dev/null | grep "new file:" &> /dev/null; then
		clr_magenta -n " (new)"
	fi

        if echo -n "${status}" 2> /dev/null | grep "renamed:" &> /dev/null; then
		dirty=1
	fi

        if echo -n "${status}" 2> /dev/null | grep "deleted:" &> /dev/null; then
		dirty=1
	fi

        if echo -n "${status}" 2> /dev/null | grep "modified:" &> /dev/null; then
		dirty=1
	fi

        if [ $dirty -eq 1 ]; then
		clr_magenta -n " (dirty)"
	fi

        if echo -n "${status}" 2> /dev/null | grep "Untracked files:" &> /dev/null; then
		clr_magenta -n " (untracked)"
	fi

        if echo -n "${status}" 2> /dev/null | grep "Changes not staged for commit" &> /dev/null; then
		clr_magenta -n " (not_staged)"
	fi

        if echo -n "${status}" 2> /dev/null | grep "Your branch is ahead of" &> /dev/null; then
		clr_magenta -n " (can_push)"
	fi

        if echo -n "${status}" 2> /dev/null | grep "Your branch is behind" &> /dev/null; then
		clr_magenta -n " (can_pull)"
	fi
}

function colorize_return_code() {
	RETVAL=$?
	if [ $RETVAL -eq 0 ]; then
		clr_green 0
	else
		clr_red $RETVAL
	fi
}

function current_date_time() {
	clr_cyan "$(date '+%Y-%m-%d %H:%M:%S')"
}

function colorize_userhost() {
	clr_green "${USER}@$(hostname -s)"
}

function colorize_pwd() {
	clr_blue "$PWD"
}

export PS1="\n\`current_date_time\` [\`parse_git_branch\`\`parse_git_dirty\`]\n\`colorize_userhost\`:\`colorize_pwd\`:\`colorize_return_code\`\$ "

# Basic environment settings
#PS1='\u@\h:\w\$ '
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
