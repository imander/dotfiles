DIR				:= $(shell pwd)
GIT				:= $(shell git describe --always --dirty)
PLUGDIR		:= $(DIR)/.vim/pack/plugins/start
GH				:= https://github.com
zsh_dir   := ~/.oh-my-zsh

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
zsh: $(zsh_dir)
	@ln -sfn $(DIR)/.zshrc $(HOME)/.zshrc
	@ln -sfn $(DIR)/zsh_themes/* $(HOME)/.oh-my-zsh/custom/themes/

$(zsh_dir): 
	@wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh 
	@sh install.sh --unattended
	@$(RM) install.sh

.PHONY: bash
bash:
	@ln -sfn "$(DIR)/.bashrc" "$(HOME)/.bashrc"

.PHONY: tmux
tmux:
	@ln -sfn "$(DIR)/.tmux.conf" "$(HOME)/.tmux.conf"
	@ln -sfn "$(DIR)/.tmux.conf.local" "$(HOME)/.tmux.conf.local"

.PHONY: vim
vim:
	$(eval GIT := .git)
	@$(RM) -r $(PLUGDIR)
	@mkdir -p $(PLUGDIR)
	@cd $(PLUGDIR) && while read line; do git clone $(GH)/$$line$(GIT); done < $(DIR)/vim.plugins
	@ln -sfn $(DIR)/.vimrc $(HOME)/.vimrc
	@ln -sfn $(DIR)/.vim $(HOME)/.vim

vim-ycm:
	@cd $(PLUGDIR)/YouCompleteMe && git submodule update --init --recursive && \
	python install.py

.PHONY: commit
commit:
ifneq (,$(findstring dirty,$(GIT)))
	git add --all
	git commit -m 'Update dotfiles'
	git push origin master
endif

	
