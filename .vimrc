syntax enable
set number
set relativenumber
set autowrite

" use the system clipboard
" set clipboard=unnamedplus

" map jk to exit insert mode
inoremap jk <Esc>
" map jkl to exit insert mode and write changes
inoremap jkl <Esc> w:<cr>

" Mappings for leader keys
nnoremap <leader>ft :NERDTreeToggle<cr>
nnoremap <leader>w :w<cr>
noremap <leader>q :q<cr>

nnoremap <leader>s :set spell!<cr>
" fix spelling with first suggestion
nnoremap <leader>f 1z=

" record macro with qq stop with q and apply with Q
nnoremap Q @q
vnoremap Q :norm @q<cr>

" toggle through buffers with shift+direction
noremap <S-l> :bnext<cr>
noremap <S-h> :bprevious<cr>
noremap <leader>bd :bdelete<cr>

set pastetoggle=<leader>z


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


" disable tab complete for you complete me
" this is usefule since tab is used for ultisnips
let g:ycm_key_list_select_completion=[]
let g:ycm_key_list_previous_completion=[]

" Set ultisnips triggers
let g:UltiSnipsExpandTrigger="<tab>"
let g:UltiSnipsJumpForwardTrigger="<tab>"
let g:UltiSnipsJumpBackwardTrigger="<s-tab>"
