#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Default PS1
export PS1='[\d][\t]\u on \h\n\w $ '

# Additional local paths
export PATH="$PATH:$HOME/.local/bin"
export PATH="$PATH:$HOME/.local/usr/bin"
export PATH="$PATH:$HOME/.local/usr/local/bin"

export ANDROID_HOME="$HOME/Android/Sdk"

# Quit the shell like in vim
alias :q="exit"

# Keep OS compatibility
case "$(uname)" in
	Linux)
		alias ls="ls --color=auto"
		usr="/usr"
		;;
	FreeBSD)
		alias ls="ls -G"
		usr="/usr/local"
		;;
	*)
		alias ls="ls --color=auto"
		usr="/usr"
		;;
esac

# Colorfull manpages
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

# Helpfull functions
exists() {
	hash $@ 2> /dev/null
}

is_function() {
	function=$(type $@ 2> /dev/null | awk '/is a function/ { print "1" }')
	if [ -n "$function" ]; then
		return 0
	else
		return 1
	fi
}

is_alias() {
	alias=$(type $1 2> /dev/null | awk '/is aliased to/ { print "1" }')
	if [ -n "$alias" ]; then
		return 0
	else
		return 1
	fi
}

# Set autocomplete for sudo
if exists complete && exists sudo; then
	complete -cf sudo
fi

# Jupiterbroadcasting live stream
if exists mpv; then
	alias jblive='mpv rtmp://videocdn-us.geocdn.scaleengine.net/jblive/live/jblive.stream'
elif exists vlc; then
	alias jblive='vlc rtmp://videocdn-us.geocdn.scaleengine.net/jblive/live/jblive.stream'
fi

# Set the default editor
if exists nvim; then
	export EDITOR="nvim"
elif exists vim; then
	export EDITOR="vim"
elif exists vi; then
	export EDITOR="vi"
fi

vim() {
	vim_bin=$(whereis -b -B $(sed "s/:/ /g" <(echo $PATH)) -f $EDITOR | cut -d' ' -f2-)
	if [[ -z $@ ]]; then
		$vim_bin
	elif [[ -d $@ ]]; then
		dir=$(pwd)
		cd $@ && $vim_bin && cd $dir
	else
		$vim_bin $@
	fi
}

# Programming language specifics
if exists go; then
	export GOPATH="$HOME/programming/go"
	export PATH="$PATH:$GOPATH/bin"
fi

if exists gem; then
	export GEM_HOME="$(ruby -e 'print Gem.user_dir')/bin"
	export PATH="$PATH:$GEM_HOME"
fi

# Ezjail shortcuts
if exists ezjail-admin && exists sudo; then
	jl() {
		sudo ezjail-admin $1 $2\.tomvanderlee.com
	}
fi

# Showbanned ipadresses
if exists pfctl && exists sudo; then
	showbanned ()
	{
		for table in "fail2ban" "permaban"; do
			banned=$(sudo pfctl -t $table -T show 2> /dev/null)

			if [ -z "$banned" ]; then
				nrBanned="0"
			else
				nrBanned=$(echo "$banned" | wc -l | awk '{ print $1 }')
			fi

			echo -e "$table ($nrBanned)\n$banned"
		done
	}
fi

# Always use pacaur even if it is not installed
if (exists pacman && ! exists pacaur) && exists sudo; then
	alias pacaur="sudo pacman"
fi

# Set the default pager
if exists less; then
	export PAGER="less"
fi

# Set the virtualenv parameters
if exists virtualenvwrapper.sh; then
	export WORKON_HOME=$HOME/.virtualenvs
	source $use/bin/virtualenvwrapper.sh
fi

# Start gnome-keyring-daemon
if exists gnome-keyring-daemon; then
	if [ -n "$DESKTOP_SESSION" ];then
		eval $(gnome-keyring-daemon --start 2> /dev/null)
		export SSH_AUTH_SOCK
	fi
fi

# Fancy bash prompt
if exists liquidprompt; then
	source liquidprompt
fi

# Fancy system info
if exists archey3; then
	archey3
elif exists screenfetch; then
	screenfetch
fi

# vim: set ts=8 sw=8 tw=0 noet :
