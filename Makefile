NUMIX-NO-TITLE = .local/share/themes/numix-no-title
BASHRC = .bashrc
VIMRC = .vimrc
HERBSTLUFT = .config/herbstluftwm

install: all

all:  bash vim numix-no-title herbstluft

numix-no-title: 
	#create wm theme dir if not exist
	mkdir -p  ~/$(NUMIX-NO-TILE)

	#remove content if existing
	-rm -rf ~/$(NUMIX-NO-TILE)/*

	#copy new contents in
	cp -rf $(NUMIX-NO-TILE)/* ~/$(NUMIX-NO-TITLE)/

herbstluftwm:
	#create herbstluftwm if not exist
	mkdir -p ~/$(HERBSTLUFT)

	#remove content if existing
	-rm -rf ~/$(HERBSTLUFT)/*

	#copy new contents in 
	cp -rf $(HERBSTLUFT)/* ~/$(HERBSTLUFT)/

bash:
	#copy bashrc to home
	cp -f $(BASHRC) ~

vim:
	#copy vimrc to home
	cp -f $(VIMRC) ~

uninstall: 
	#remove all
	-rm -rf ~/$(WM-THEME-DIR)
	-rm -rf ~/$(HERBSTLUFT)
	-rm -f ~/$(BASHRC)
	-rm -f ~/$(VIMRC)
