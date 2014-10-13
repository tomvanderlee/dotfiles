PWD=$(shell pwd)

THEMES_DIR = .local/share/themes
CONFIG_DIR = .config
GTK3_DIR = gtk-3.0

BASHRC = .bashrc
COMPTON = .compton
GTKCSS = gtk.css
HERBSTLUFT = herbstluftwm
LIQUIDPROMPT = .liquidpromptrc
LP_PS1 = .lp_ps1
NUMIX = numix-no-title
VIMRC = .vimrc
XRESOURCES = .Xresources

install: all

all:  bash compton gtk3fix herbstluftwm liquidprompt numix-no-title vim xresources 

bash:
	ln -sf $(PWD)/$(BASHRC) ~

compton:
	ln -sf $(PWD)/$(COMPTON) ~

gtk3fix:
	mkdir -p ~/$(CONFIG_DIR)/$(GTK3_DIR)
	ln -sf $(PWD)/$(CONFIG_DIR)/$(GTK3_DIR)/$(GTKCSS) ~/$(CONFIG_DIR)/$(GTK3_DIR)

herbstluftwm:
	mkdir -p ~/$(CONFIG_DIR)
	ln -sf $(PWD)/$(CONFIG_DIR)/$(HERBSTLUFT) ~/$(CONFIG_DIR)/

liquidprompt:
	ln -sf $(PWD)/$(LIQUIDPROMPT) ~
	ln -sf $(PWD)/$(LP_PS1) ~

numix-no-title:
	mkdir -p ~/$(THEMES_DIR)
	ln -sf $(PWD)/$(THEMES_DIR)/$(NUMIX) ~/$(THEMES_DIR)/

vim:
	ln -sf $(PWD)/$(VIMRC) ~

xresources:
	ln -sf $(PWD)/$(XRESOURCES) ~

uninstall:
	#remove all
	-rm ~/$(BASHRC)
	-rm ~/$(COMPTON)
	-rm ~/$(CONFIG_DIR)/$(HERBSTLUFT)
	-rm ~/$(CONFIG_DIR)/$(GTK3_DIR)/$(GTKCSS)
	-rm ~/$(LIQUIDPROMPT)
	-rm ~/$(LP_PS1)
	-rm ~/$(THEMES_DIR)/$(NUMIX)
	-rm ~/$(VIMRC)
	-rm ~/$(XRESOURCES)
