#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

export PS1='[\d][\t]\u on \h\n\w => '

export PATH="$PATH:$HOME/.local/bin"
export PATH="$PATH:$HOME/.local/usr/bin"
export PATH="$PATH:$HOME/.local/usr/local/bin"

alias :q="exit"

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
		;;
esac

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

if exists complete && exists sudo; then
	complete -cf sudo
fi

if exists mpv; then
	alias jblive='mpv rtmp://videocdn-us.geocdn.scaleengine.net/jblive/live/jblive.stream'
elif exists vlc; then
	alias jblive='vlc rtmp://videocdn-us.geocdn.scaleengine.net/jblive/live/jblive.stream'
fi

if exists vim; then
	export EDITOR="vim"
	vim() {
		if [[ -z $@ ]]; then
			$usr/bin/vim
		elif [[ -d $@ ]]; then
			dir=$(pwd)
			cd $@ && $usr/bin/vim && cd $dir
		else
			$usr/bin/vim $@
		fi
	}
fi

if exists go; then
	export GOPATH="$HOME/programming/go"
	export PATH="$PATH:$GOPATH/bin"
fi

if exists gem; then
	export GEM_HOME="$(ruby -e 'print Gem.user_dir')/bin"
	export PATH="$PATH:$GEM_HOME"
fi

if exists ezjail-admin && exists sudo; then
	jl() {
		sudo ezjail-admin $1 $2\.tomvanderlee.com
	}
fi

if exists pfctl && exists sudo; then
	showbanned ()
	{
		for table in "fail2ban" "permaban"; do
			banned=$(sudo pfctl -t $table -T show 2> /dev/null)
			echo -e "$table\n$banned"
		done
	}
fi

if (exists pacman && !exists pacaur) && exists sudo; then
	alias pacaur="sudo pacman"
fi

if exists less; then
	export PAGER="less"
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
