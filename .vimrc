syntax enable
set number
set relativenumber
set autowrite

" use the system clipboard
" set clipboard=unnamedplus

" map jk to exit insert mode
inoremap jk <Esc>

set tabstop=2
set shiftwidth=2
set expandtab

let g:go_highlight_functions = 1
let g:go_highlight_function_calls = 1
let g:rehash256 = 1
let g:molokai_original = 1
colorscheme molokai

" better defaults for moving between panes
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

let mapleader = "\<Space>"

" edit vimrc quickly and reload .vimrc
map <leader>v :edit ~/.vimrc<cr>
autocmd! bufwritepost .vimrc source %

let g:airline#extensions#tabline#enabled = 1

" set nerdtree toggle shortcut and make open at startup
map <leader>ft :NERDTreeToggle<cr>
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif
autocmd VimEnter * set winfixwidth
let g:NERDTreeNodeDelimiter = "\u00a0"
let NERDTreeAutoDeleteBuffer = 1
let NERDTreeMinimalUI = 1
let NERDTreeDirArrows = 1
let NERDTreeQuitOnOpen = 1

" Quit vim if nerdtree is only buffer open
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

