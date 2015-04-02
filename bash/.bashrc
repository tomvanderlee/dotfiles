#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias jblive='mpv rtmp://videocdn-us.geocdn.scaleengine.net/jblive/live/jblive.stream 2> /dev/null &' 

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
	if [[ -z $@ ]]; then
		/usr/bin/vim
	elif [[ -d $@ ]]; then
		dir=$(pwd)
		cd $@ && /usr/bin/vim && cd $dir
	else
		/usr/bin/vim $@
	fi
}

export PS1='[\d][\t]\u on \h\n\w => '
export GOPATH="$HOME/programming/go"
export GEM_HOME="$(ruby -e 'print Gem.user_dir')/bin"
export PATH="$PATH:$GEM_HOME:$GOPATH/bin"
export EDITOR="vim"

source liquidprompt
archey3

# vim: set ts=8 sw=8 tw=0 noet :
