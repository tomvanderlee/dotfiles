PWD=$(shell pwd)

THEMES_DIR = .local/share/themes
CONFIG_DIR = .config

NUMIX = numix-no-title
HERBSTLUFT = herbstluftwm

BASHRC = .bashrc
COMPTON = .compton
LIQUIDPROMPT = .liquidpromptrc
LP_PS1 = .lp_ps1
VIMRC = .vimrc
XRESOURCES = .Xresources


install: all

all:  bash compton liquidprompt vim xresources numix-no-title herbstluftwm

numix-no-title:
	mkdir -p ~/$(THEMES_DIR)
	ln -sf $(PWD)/$(THEMES_DIR)/$(NUMIX) ~/$(THEMES_DIR)/

herbstluftwm:
	mkdir -p ~/$(CONFIG_DIR)
	ln -sf $(PWD)/$(CONFIG_DIR)/$(HERBSTLUFT) ~/$(CONFIG_DIR)/

bash:
	ln -sf $(PWD)/$(BASHRC) ~

compton:
	ln -sf $(PWD)/$(COMPTON) ~

liquidprompt:
	ln -sf $(PWD)/$(LIQUIDPROMPT) ~
	ln -sf $(PWD)/$(LP_PS1) ~

vim:
	ln -sf $(PWD)/$(VIMRC) ~

xresources:
	ln -sf $(PWD)/$(XRESOURCES) ~

uninstall:
	#remove all
	-rm ~/$(THEMES_DIR)/$(NUMIX)
	-rm ~/$(CONFIG_DIR)/$(HERBSTLUFT)
	-rm ~/$(BASHRC)
	-rm ~/$(COMPTON)
	-rm ~/$(LIQUIDPROMPT)
	-rm ~/$(LP_PS1)
	-rm ~/$(VIMRC)
	-rm ~/$(XRESOURCES)
