SHELL    := '/bin/bash'
DIR      := $(shell pwd)
GIT      := $(shell git describe --always --dirty)
PLUGDIR  := $(DIR)/.vim/pack/plugins/start
GH       := https://github.com
zsh_dir  := ~/.oh-my-zsh

# Filetype plugin for vim-markdown
VIM_MD := .vim/after/ftplugin/markdown/instant-markdown.vim

.PHONY: all
all: bin env alias zsh bash vim tmux

.PHONY: bin
bin:
	@ln -sfn "$(DIR)/bin" "$(HOME)/bin"

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
	cp -r conky-fonts "$(HOME)/.local/share/fonts/"
	ln -sfn "$(DIR)/conky" "$(HOME)/.config/conky"

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
	@mkdir -p $(PLUGDIR)
	@cd $(PLUGDIR) && while read line; do \
		plug_dir=`cut -d/ -f2 <<< $$line`; \
		if [[ ! -z $$line ]] && [[ ! -d $$plug_dir ]]; then \
			git clone $(GH)/$$line$(GIT); \
		fi \
	done < $(DIR)/vim.plugins 
	@ln -sfn $(DIR)/.vimrc $(HOME)/.vimrc
	@ln -sfn $(DIR)/.vim $(HOME)/.vim
	@$(MAKE) $(PLUGDIR)/coc.nvim-release $(VIM_MD) clean-plugins

$(PLUGDIR)/coc.nvim-release:
	cd $(PLUGDIR) && curl --fail -L https://github.com/neoclide/coc.nvim/archive/release.tar.gz|tar xzfv -
	vim -c 'CocInstall -sync coc-go|q'
	vim -c 'CocInstall -sync coc-json|q'
	vim -c 'CocInstall -sync coc-snippets|q'

$(VIM_MD):
	mkdir -p '.vim/after/ftplugin/markdown/'
	cp $(PLUGDIR)/vim-instant-markdown/after/ftplugin/markdown/instant-markdown.vim .vim/after/ftplugin/markdown/
	sudo npm -g install instant-markdown-d

.PHONY: clean-plugins
clean-plugins:
	@cat $(DIR)/vim.plugins | cut -f2 -d/ > desired_plugins
	@ls -1 $(PLUGDIR) > current_plugins
	@grep -vf desired_plugins current_plugins |grep -v coc.nvim-release | while read line; do \
		echo removing $(PLUGDIR)/$$line; \
		rm -rf $(PLUGDIR)/$$line; \
	done 
	@$(RM) desired_plugins current_plugins

.PHONY: commit
commit:
ifneq (,$(findstring dirty,$(GIT)))
	git add --all
	git commit -m 'Update dotfiles'
	git push origin master
endif

	
