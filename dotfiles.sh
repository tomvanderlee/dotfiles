#!/usr/bin/env bash

DOTFILES=$HOME/dotfiles
DOTFILESRC=$DOTFILES/dotfilesrc
PATH=$PATH:$DOTFILES/dotfiles/bin

dotfiles --repo="$DOTFILES" --config="$DOTFILESRC" $@
