DIR := $(shell pwd)
GIT := $(shell git describe --always --dirty)

.PHONY: all
all: vim

.PHONY: vim
vim:
	@rm "$(HOME)/.vimrc"
	@rm "$(HOME)/.vim"
	@ln -s "$(DIR)/vimrc" "$(HOME)/.vimrc"
	@ln -s "$(DIR)/vim" "$(HOME)/.vim"

.PHONY: commit
commit:
ifneq (,$(findstring dirty,$(GIT)))
	git add --all
	git commit -m 'Update dotfiles'
	git push origin master
endif

	
