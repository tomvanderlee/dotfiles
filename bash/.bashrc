# If not running interactively, don't do anything
[[ $- != *i* ]] && return

[ -f "/etc/bashrc" ] && source "/etc/bashrc"

# Default PS1
export PS1='[\d][\t]\u on \h\n\w $ '

# Additional local paths
export PATH="$PATH:$HOME/.cargo/bin"
export PATH="$PATH:$HOME/.local/bin"
export PATH="$PATH:$HOME/.local/usr/bin"
export PATH="$PATH:$HOME/.local/usr/local/bin"

export C_INCLUDE_PATH="$C_INCLUDE_PATH:$HOME/.local/include"
export C_INCLUDE_PATH="$C_INCLUDE_PATH:$HOME/.local/usr/include"
export C_INCLUDE_PATH="$C_INCLUDE_PATH:$HOME/.local/usr/local/include"

export CPLUS_INCLUDE_PATH="$CPLUS_INCLUDE_PATH:$HOME/.local/include"
export CPLUS_INCLUDE_PATH="$CPLUS_INCLUDE_PATH:$HOME/.local/usr/include"
export CPLUS_INCLUDE_PATH="$CPLUS_INCLUDE_PATH:$HOME/.local/usr/local/include"

export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$HOME/.local/lib"
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$HOME/.local/usr/lib"
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$HOME/.local/usr/local/lib"

export ANDROID_HOME="$HOME/Android/Sdk"
export PATH="$PATH:$ANDROID_HOME/platform-tools"

# Quit the shell like in vim
alias :q="exit"

# Keep OS compatibility
case "$(uname)" in
    Linux)
        alias ls="ls --color=auto"
        usr="/usr"
        ;;
    Darwin)

        alias flushdns="sudo killall -HUP mDNSResponder;sudo killall mDNSResponderHelper;sudo dscacheutil -flushcache"
        alias ls="ls -G"
        usr="/usr/local"
        ;;
    FreeBSD)
        alias ls="ls -G"
        usr="/usr/local"
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
    type $@ &> /dev/null
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

tunnel() {
    ssh -R ${1}:80:127.0.0.1:${2} serveo.net
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
    vim_bin=$(which $EDITOR)
    if [[ -z "$@" ]]; then
        $vim_bin
    elif [[ -d "$@" ]]; then
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
    export GEM_HOME="$(ruby -e 'print Gem.user_dir')"
    export PATH="$GEM_HOME/bin:$PATH"
fi

# Ezjail shortcuts
if exists ezjail-admin && exists sudo; then
    jl() {
        sudo ezjail-admin $1 $2\.tomvanderlee.com
    }
fi

# Showbanned ipadresses
if exists pfctl && exists sudo; then
    showbanned () {
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

if exists virtualenv; then
    export VIRTUALENV_ALWAYS_COPY=1
fi

# Set the virtualenv parameters
if exists virtualenvwrapper.sh; then
    export WORKON_HOME=$HOME/.virtualenvs
    source $(which virtualenvwrapper.sh) 2> /dev/null
fi

# Start gnome-keyring-daemon
if exists gnome-keyring-daemon; then
    if [ -n "$DESKTOP_SESSION" ];then
        eval $(gnome-keyring-daemon --start 2> /dev/null)
        export SSH_AUTH_SOCK
    fi
fi

if exists sensible.bash; then
    source sensible.bash
fi

# Fancy bash prompt
if exists liquidprompt; then
    source $(which liquidprompt) 2> /dev/null
elif [ -f "/usr/share/liquidprompt/liquidprompt" ]; then
    source /usr/share/liquidprompt/liquidprompt 2> /dev/null
fi

# Fancy system info
if exists archey3; then
    archey3
elif exists screenfetch; then
    screenfetch
fi

if exists brew; then
    BASH_COMPLETION="$(brew --prefix)/etc/bash_completion"
    if [ -f "${BASH_COMPLETION}" ]; then
        source "${BASH_COMPLETION}"
    fi
fi

if exists lpass; then
    if exists complete; then
        _complete_lpass_accounts() {
            local search items item cmp newline

            newline='
            '

            cmp=${COMP_WORDS[COMP_CWORD]}
            search="$(sed 's/\\\ /___/g' <<< $cmp)"

            if [ -z "$search" ]; then
                return
            fi

            items=$(lpass ls --format "%an$newline%aN" | sed "s/\ /___/g")

            for item in $items; do
                if [[ $item =~ ^$search ]]; then
                    COMPREPLY+=( "$(sed 's/___/\\\ /g' <<< $item)" )
                fi
            done
        }

        complete -F _complete_lpass_accounts lpcp
    fi

    lps() {
        lpass ls --format "%aN" | grep $1
    }

    lpcp() {
        lpass show --password "$1" | pbcopy
        sleep 1
        lpass show --username "$1" | pbcopy
    }
fi

# heroku autocomplete setup
if exists heroku; then
    case "$(uname)" in
        Darwin)
            HEROKU_AC_BASH_SETUP_PATH=$HOME/Library/Caches/heroku/autocomplete/bash_setup
            ;;
    esac

    test -f $HEROKU_AC_BASH_SETUP_PATH \
        && source $HEROKU_AC_BASH_SETUP_PATH
fi

if exists pyenv; then
    export PATH="$PATH:$(pyenv root)/shims"
fi

if exists python3; then
    alias pyhttpd="python3 -m http.server"
fi

if [ -s "/usr/local/opt/nvm/nvm.sh" ]; then
    export NVM_DIR="$HOME/.nvm"
    source "/usr/local/opt/nvm/nvm.sh"
fi

# vim: set ts=4 sw=4 tw=0 et :
