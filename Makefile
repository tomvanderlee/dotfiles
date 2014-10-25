ALL=$(shell ls -p | grep "/")
HOME=$(shell echo ~)

install:
	@echo "Installing dotfiles to $(HOME)"
	@stow -t $(HOME) -v $(ALL)

uninstall:
	@echo "Uninstalling dotfiles"
	@stow -t $(HOME) -Dv $(ALL)
