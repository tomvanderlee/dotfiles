#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

export PS1='[\d][\t]\u on \h\n\w => '
export TERM="xterm-256color"

alias ls='ls --color=auto'

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

exists() {
	hash $@ 2> /dev/null
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

if exists mpv; then
	alias jblive='mpv rtmp://videocdn-us.geocdn.scaleengine.net/jblive/live/jblive.stream'
elif exists vlc; then
	alias jblive='vlc rtmp://videocdn-us.geocdn.scaleengine.net/jblive/live/jblive.stream'
fi

if exists vim; then
	export EDITOR="vim"
fi

if exists go; then
	export GOPATH="$HOME/programming/go"
	export PATH="$PATH:$GOPATH/bin"
fi

if exists gem; then
	export GEM_HOME="$(ruby -e 'print Gem.user_dir')/bin"
	export PATH="$PATH:$GEM_HOME"
fi

if exists liquidprompt; then
	source liquidprompt
fi

if exists archey3; then
	archey3
elif exists screenfetch; then
	screenfetch
fi

# vim: set ts=8 sw=8 tw=0 noet :
