DIR := $(shell pwd)
GIT := $(shell git describe --always --dirty)

.PHONY: all
all: env alias zsh vim tmux

.PHONY: env
env:
	@$(RM) "$(HOME)/.env"
	@ln -s "$(DIR)/.env" "$(HOME)/.env"
	@touch "$(HOME)/.env.local"

.PHONY: alias
alias:
	@$(RM) "$(HOME)/.alias"
	@ln -s "$(DIR)/.alias" "$(HOME)/.alias"

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
	@$(RM) "$(HOME)/.oh-my-zsh/themes/bira-imander.zsh-theme"
	@ln -s "$(DIR)/.zshrc" "$(HOME)/.zshrc"
	@ln -s "$(DIR)/oh-my-zsh" "$(HOME)/.oh-my-zsh"
	@ln -s "$(DIR)/bira-imander.zsh-theme" "$(HOME)/.oh-my-zsh/themes/bira-imander.zsh-theme"

.PHONY: bash
bash:
	@$(RM) "$(HOME)/.bashrc"
	@ln -s "$(DIR)/.bashrc" "$(HOME)/.bashrc"

.PHONY: tmux
tmux:
	@$(RM) "$(HOME)/.tmux.conf"
	@$(RM) "$(HOME)/.tmux.conf.local"
	@ln -s "$(DIR)/.tmux.conf" "$(HOME)/.tmux.conf"
	@ln -s "$(DIR)/.tmux.conf.local" "$(HOME)/.tmux.conf.local"

.PHONY: vim
vim:
	@$(RM) "$(HOME)/.vimrc"
	@$(RM) "$(HOME)/.vim"
	@ln -s "$(DIR)/.vimrc" "$(HOME)/.vimrc"
	@ln -s "$(DIR)/.vim" "$(HOME)/.vim"

.PHONY: commit
commit:
ifneq (,$(findstring dirty,$(GIT)))
	git add --all
	git commit -m 'Update dotfiles'
	git push origin master
endif

	
