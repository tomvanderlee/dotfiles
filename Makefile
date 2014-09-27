PWD=$(shell pwd)

THEMES_DIR = .local/share/themes
CONFIG_DIR = .config
NUMIX = numix-no-title
BASHRC = .bashrc
VIMRC = .vimrc
HERBSTLUFT = herbstluftwm
XRESOURCES = .Xresources


install: all

all:  bash vim xresources numix-no-title herbstluftwm

numix-no-title:
	ln -sf $(PWD)/$(THEMES_DIR)/$(NUMIX) ~/$(THEMES_DIR)

herbstluftwm:
	ln -sf $(PWD)/$(CONFIG_DIR)/$(HERBSTLUFT) ~/$(CONFIG_DIR)

bash:
	ln -sf $(PWD)/$(BASHRC) ~

vim:
	ln -sf $(PWD)/$(VIMRC) ~

xresources:
	ln -sf $(PWD)/$(XRESOURCES) ~

uninstall:
	#remove all
	-rm ~/$(THEMES_DIR)/$(NUMIX)
	-rm ~/$(CONFIG_DIR)/$(HERBSTLUFT)
	-rm ~/$(BASHRC)
	-rm ~/$(VIMRC)
	-rm ~/$(XRESOURCES)
