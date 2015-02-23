#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

cd() {
	builtin cd "$@" && ls -A	
}

pacaur() {
	env pacman_program="pacaur" /usr/bin/pacmatic "$@"
}

man() {
    env LESS_TERMCAP_mb=$'\E[01;31m' \
    LESS_TERMCAP_md=$'\E[01;38;5;74m' \
    LESS_TERMCAP_me=$'\E[0m' \
    LESS_TERMCAP_se=$'\E[0m' \
    LESS_TERMCAP_so=$'\E[38;5;246m' \
    LESS_TERMCAP_ue=$'\E[0m' \
    LESS_TERMCAP_us=$'\E[04;38;5;146m' \
    man "$@"
}

vim() {
	(cd $@ && /usr/bin/vim) || /usr/bin/vim $@
}

alias ls='ls --color=auto'
alias jblive='vlc rtmp://videocdn-us.geocdn.scaleengine.net/jblive/live/jblive.stream 2> /dev/null &' 


export PS1='[\d][\t]\u on \h\n\w => '
export GOPATH="$HOME/programming/go"
export PATH="$PATH:$GOPATH/bin"
export EDITOR="vim"

source liquidprompt
archey3
