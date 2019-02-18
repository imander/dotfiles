DIR := $(shell pwd)

.PHONY: all
all: vim

.PHONY: vim
vim:
	@ln -s "$(DIR)/vimrc" "$(HOME)/.vimrc"
	@ln -s "$(DIR)/vim" "$(HOME)/.vim"
