DIR := $(shell pwd)
GIT := $(shell git describe --always --dirty)

.PHONY: all
all: submods env alias zsh bash vim tmux

.PHONY: submods
submods:
	@git submodule update --init --recursive --merge

.PHONY: env
env:
	@ln -sfn "$(DIR)/.env" "$(HOME)/.env"
	@touch "$(HOME)/.env.local"

.PHONY: alias
alias:
	@ln -sfn "$(DIR)/.alias" "$(HOME)/.alias"

.PHONY: conky
conky:
ifeq (, $(shell which conky))
	sudo pacman -S conky
endif
	@ln -sfn "$(DIR)/conky" "$(HOME)/.config/conky"

.PHONY: zsh
zsh:
	@ln -sfn "$(DIR)/.zshrc" "$(HOME)/.zshrc"
	@ln -sfn "$(DIR)/oh-my-zsh" "$(HOME)/.oh-my-zsh"
	@ln -sfn "$(DIR)/bira.zsh-theme" "$(HOME)/.oh-my-zsh/custom/themes/bira.zsh-theme"
	@ln -sfn "$(DIR)/avit.zsh-theme" "$(HOME)/.oh-my-zsh/custom/themes/avit.zsh-theme"

.PHONY: bash
bash:
	@ln -sfn "$(DIR)/.bashrc" "$(HOME)/.bashrc"

.PHONY: tmux
tmux:
	@ln -sfn "$(DIR)/.tmux.conf" "$(HOME)/.tmux.conf"
	@ln -sfn "$(DIR)/.tmux.conf.local" "$(HOME)/.tmux.conf.local"

.PHONY: vim
vim:
	@ln -sfn "$(DIR)/.vimrc" "$(HOME)/.vimrc"
	@ln -sfn "$(DIR)/.vim" "$(HOME)/.vim"

.PHONY: commit
commit:
ifneq (,$(findstring dirty,$(GIT)))
	git add --all
	git commit -m 'Update dotfiles'
	git push origin master
endif

	
