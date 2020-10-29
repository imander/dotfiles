SHELL    := '/bin/bash'
DIR      := $(shell pwd)
GIT      := $(shell git describe --always --dirty)
PLUGDIR  := $(DIR)/.vim/pack/plugins/start
GH       := https://github.com
zsh_dir  := $(HOME)/.oh-my-zsh

# Filetype plugin for vim-markdown
VIM_MD := .vim/after/ftplugin/markdown/instant-markdown.vim

UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Linux)
	PKG_DIR = packages/arch
endif
ifeq ($(UNAME_S),Darwin)
	PKG_DIR = packages/osx
endif

.PHONY: all
all: zsh bash bin env alias config vim tmux packages

.PHONY: bin
bin:
	ln -sfn "$(DIR)/bin" "$(HOME)/bin"

.PHONY: env
env:
	ln -sfn "$(DIR)/.env" "$(HOME)/.env"
	touch "$(HOME)/.env.local"

.PHONY: alias
alias:
	ln -sfn "$(DIR)/.alias" "$(HOME)/.alias"

.PHONY: config
config:
	mkdir -p "$(HOME)/.config"
	ln -sfn "$(DIR)/.config/flake8" "$(HOME)/.config/flake8"
	ln -sfn "$(DIR)/.editorconfig" "$(HOME)/.editorconfig"

.PHONY: conky
conky:
ifeq (, $(shell which conky))
	sudo pacman -S conky
endif
	cp -r conky-fonts "$(HOME)/.local/share/fonts/"
	ln -sfn "$(DIR)/conky" "$(HOME)/.config/conky"

.PHONY: zsh
zsh: $(zsh_dir)
	ln -sfn $(DIR)/.zshrc $(HOME)/.zshrc
	ln -sfn $(DIR)/zsh_themes/* $(HOME)/.oh-my-zsh/custom/themes/

$(zsh_dir):
	@wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh
	@sh install.sh --unattended
	@$(RM) install.sh

.PHONY: bash
bash:
	ln -sfn "$(DIR)/.bashrc" "$(HOME)/.bashrc"

.PHONY: tmux
tmux:
	ln -sfn "$(DIR)/.tmux.conf" "$(HOME)/.tmux.conf"
	ln -sfn "$(DIR)/.tmux.conf.local" "$(HOME)/.tmux.conf.local"

.PHONY: vim
vim: formatters
	@mkdir -p $(PLUGDIR)
	@cd $(PLUGDIR) && while read line; do \
		plug_dir=`cut -d/ -f2 <<< $$line`; \
		if [[ ! -z $$line ]] && [[ ! -d $$plug_dir ]]; then \
			git clone $(GH)/$${line}.git; \
		fi \
	done < $(DIR)/vim.plugins
	@ln -sfn $(DIR)/.vimrc $(HOME)/.vimrc
	@ln -sfn $(DIR)/.vim $(HOME)/.vim
	@$(MAKE) $(PLUGDIR)/coc.nvim-release $(VIM_MD) clean-plugins

$(PLUGDIR)/coc.nvim-release:
	cd $(PLUGDIR) && curl --fail -L https://github.com/neoclide/coc.nvim/archive/release.tar.gz|tar xzfv -
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

.PHONY: formatters
formatters:
	pip3 install --user sqlparse
	which shfmt || go get -u mvdan.cc/sh/cmd/shfmt

.PHONY: packages
packages:
	$(PKG_DIR)/install.sh

.PHONY: commit
commit:
ifneq (,$(findstring dirty,$(GIT)))
	git add --all
	git commit -m 'Update dotfiles'
	git push origin master
endif


