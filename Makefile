SHELL    := '/bin/bash'
DIR      := $(shell pwd)
GIT      := $(shell git describe --always --dirty)
PLUGDIR  := $(DIR)/.vim/pack/plugins/start
GH       := https://github.com
zsh_dir  := $(HOME)/.oh-my-zsh

# Filetype plugin for vim-markdown
VIM_MD := .vim/after/ftplugin/markdown/instant-markdown.vim

export PATH := $(PATH):/usr/local/go/bin:/usr/local/bin:$(HOME)/bin:$(HOME)/go/bin

UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Linux)
	ID = $(shell grep -oP '(?<=^ID=).+' /etc/os-release | tr -d '"')
	PKG_DIR = packages/$(ID)
else ifeq ($(UNAME_S),Darwin)
	PKG_DIR = packages/darwin
endif

.PHONY: all
all: packages zsh bash bin env alias config vim tmux

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
	ln -sfn "$(DIR)/gitignore" "$(HOME)/.gitignore"
	ln -sfn "$(DIR)/fzf.ignore" "$(HOME)/.fzf.ignore"
	[ -d "$(HOME)/.config/zsh-syntax-highlighting" ] || git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$(HOME)/.config/zsh-syntax-highlighting"
	git config --global pull.ff only
	git config --global user.name imander
	git config --global user.email 'github@imand3r.io'
	git config --global core.excludesfile "$(HOME)/.gitignore"
	git remote remove origin
	git remote add origin git@github.com:imander/dotfiles.git
	@$(MAKE) $(UNAME_S)-config

.PHONY: Darwin-config
Darwin-config:
	mkdir -p "$(HOME)/.config/"{karabiner,iterm}
	ln -sfn "$(DIR)/.config/karabiner.json" "$(HOME)/.config/karabiner/karabiner.json"
	ln -sfn "$(DIR)/.config/com.googlecode.iterm2.plist" "$(HOME)/.config/iterm/com.googlecode.iterm2.plist"

.PHONY: Linux-config
Linux-config:
ifneq (,$(USER))
	which zsh && sudo chsh -s "$$(which zsh)" "$(USER)"
endif
ifneq (,$(DISPLAY))
	cp -r conky-fonts "$(HOME)/.local/share/fonts/"
	ln -sfn "$(DIR)/conky" "$(HOME)/.config/conky"
endif

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
vim: formatters vim-plugins
	@ln -sfn $(DIR)/.vimrc $(HOME)/.vimrc
	@ln -sfn $(DIR)/.vim $(HOME)/.vim

.PHONY: vim-plugins
vim-plugins:
	@mkdir -p $(PLUGDIR)
	@cd $(PLUGDIR) && while read line; do \
		plug_dir=`cut -d/ -f2 <<< $$line`; \
		if [[ ! -z $$line ]] && [[ ! -d $$plug_dir ]]; then \
			git clone $(GH)/$${line}.git; \
		fi \
	done < $(DIR)/vim.plugins
	@$(MAKE) clean-plugins

$(VIM_MD):
ifneq (,$(DISPLAY))
	mkdir -p '.vim/after/ftplugin/markdown/'
	cp $(PLUGDIR)/vim-instant-markdown/after/ftplugin/markdown/instant-markdown.vim .vim/after/ftplugin/markdown/
	sudo npm -g install instant-markdown-d
endif

.PHONY: update-plugins
update-plugins:
	rm -rf $(PLUGDIR)/*
	@$(MAKE) vim

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
	which sqlformat || pip3 install --user sqlparse
	which shfmt || go get -u mvdan.cc/sh/cmd/shfmt

.PHONY: packages
packages:
ifneq (,$(PKG_DIR))
	$(PKG_DIR)/install.sh
endif

.PHONY: commit
commit:
ifneq (,$(findstring dirty,$(GIT)))
	git add --all
	git commit -m 'Update dotfiles'
	git push origin master
endif


