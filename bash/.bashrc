#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'

cd() {
	builtin cd "$@" && ls -A	
}

pacaur() {
	env pacman_program="pacaur" /usr/bin/pacmatic "$@"
}

#PS1='[\u@\h \W]\$ '
PS1='[\d][\t]\u on \h\n\w => '

alias jblive='vlc rtmp://videocdn-us.geocdn.scaleengine.net/jblive/live/jblive.stream 2> /dev/null &' 

source liquidprompt
archey
