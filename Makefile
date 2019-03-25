DIR := $(shell pwd)
GIT := $(shell git describe --always --dirty)

.PHONY: all
all: env zsh vim tmux

.PHONY: env
env:
	@$(RM) "$(HOME)/.env"
	@ln -s "$(DIR)/env" "$(HOME)/.env"

.PHONY: conky
conky:
ifeq (, $(shell which conky))
	sudo pacman -S conky
endif
	@$(RM) -r "$(HOME)/.config/conky"
	@ln -s "$(DIR)/conky" "$(HOME)/.config/conky"

.PHONY: zsh
zsh:
	@$(RM) "$(HOME)/.zshrc"
	@$(RM) -r "$(HOME)/.oh-my-zsh"
	@ln -s "$(DIR)/zshrc" "$(HOME)/.zshrc"
	@ln -s "$(DIR)/oh-my-zsh" "$(HOME)/.oh-my-zsh"

.PHONY: tmux
tmux:
	@$(RM) "$(HOME)/.tmux.conf"
	@$(RM) "$(HOME)/.tmux.conf.local"
	@ln -s "$(DIR)/tmux.conf" "$(HOME)/.tmux.conf"
	@ln -s "$(DIR)/tmux.conf.local" "$(HOME)/.tmux.conf.local"

.PHONY: vim
vim:
	@$(RM) "$(HOME)/.vimrc"
	@$(RM) "$(HOME)/.vim"
	@ln -s "$(DIR)/vimrc" "$(HOME)/.vimrc"
	@ln -s "$(DIR)/vim" "$(HOME)/.vim"

.PHONY: commit
commit:
ifneq (,$(findstring dirty,$(GIT)))
	git add --all
	git commit -m 'Update dotfiles'
	git push origin master
endif

	
