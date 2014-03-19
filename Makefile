WM-THEME-DIR = .local/share/themes/numix-no-title
BASHRC = .bashrc

install: all

all: wm-theme bash

wm-theme: 
	#create wm theme dir if not exist
	mkdir -p  ~/$(WM-THEME-DIR)

	#remove content if existing
	-rm -rf ~/$(WM-THEME-DIR)/*

	#copy contents in
	cp -rf $(WM-THEME-DIR)/* ~/$(WM-THEME-DIR)/

bash:
	#copy to home
	cp -f $(BASHRC) ~/$(BASHRC)