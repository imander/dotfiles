set rtp+=~/.fzf
syntax enable

set number
set relativenumber
set autowrite

set list
set tabstop=2
set shiftwidth=2
set expandtab
set smartcase

" Ensure undo history is not lost with buffer changes
set hidden

let mapleader = "\<Space>"
" let g:python3_host_prog = $HOME . '/.asdf/shims/python'

" shortcut to save file with sudo
command! W :execute ':silent w !sudo tee % > /dev/null' | :edit!

" map jk to exit insert mode
inoremap jk <Esc>

" Mappings for leader keys
nnoremap <leader>ft :NERDTreeToggle<cr>
nnoremap <leader>w :w<cr>
nnoremap <leader>q :q<cr>
nnoremap <leader>wq :wq<cr>
nnoremap <leader>wa :wa<cr>

" set shortcuts to copy/paste using system clipboard
noremap <Leader>y "+y
noremap <Leader>p "+p

nnoremap <leader>s :set spell!<cr>
" fix spelling with first suggestion
nnoremap <leader>fs 1z=

" record macro with qq stop with q and apply with Q
nnoremap Q @q
vnoremap Q :norm @q<cr>

" toggle through buffers with shift+direction
noremap <S-l> :bnext<cr>
noremap <S-h> :bprevious<cr>
noremap <leader>bd :bdelete<cr>

" better defaults for moving between panes
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

" execute lines with interpreters
noremap <leader>tb :terminal bash<cr>
noremap <leader>tp :terminal python<cr>
noremap <leader>p3 :terminal python3<cr>
noremap <leader>tr :terminal ruby<cr>

" fzf shortcuts
nmap <Leader>ff :Files<CR>
nmap <Leader>gf :GFiles<CR>
nmap <Leader>fh :History<CR>
nmap <Leader>fH :Helptags!<CR>
nmap <Leader>fc :History:<CR>

" autoformat
nmap <Leader>af :Autoformat<CR>

set pastetoggle=<F8>

let g:go_highlight_functions = 1
let g:go_highlight_function_calls = 1
" let g:rehash256 = 1
" let g:molokai_original = 1
" colorscheme molokai
colorscheme imander

" shortcut to edit vimrc
map <leader>v :edit ~/.vimrc<cr>

let g:airline#extensions#tabline#enabled = 1

let g:NERDTreeNodeDelimiter = "\u00a0"
let NERDTreeAutoDeleteBuffer = 1
let NERDTreeMinimalUI = 1
let NERDTreeDirArrows = 1
let NERDTreeQuitOnOpen = 1

" CoC specific configuration
"
"default extensions to install on first load
let g:coc_global_extensions = ['coc-go', 'coc-snippets', 'coc-python']

" Coc completion to use tab
inoremap <silent><expr> <TAB>
      \ pumvisible() ? coc#_select_confirm() :
      \ coc#expandableOrJumpable() ? "\<C-r>=coc#rpc#request('doKeymap', ['snippets-expand-jump',''])\<CR>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

let g:coc_snippet_next = '<tab>'

" set virtualenv directory for black python formatter
let g:black_virtualenv="~/.black/venv"

inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"

" always show signcolumns
set signcolumn=yes

" highlight the cursorline
set cursorline

" Use `[g` and `]g` to navigate diagnostics
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" You will have bad experience for diagnostic messages when it's default 4000.
set updatetime=300

" Remap for rename current word
nmap <leader>rn <Plug>(coc-rename)

" Mac specific stuff
if has("unix")
  let s:uname = system("uname")
  if s:uname == "Darwin\n"
    source /usr/local/opt/fzf/plugin/fzf.vim
  endif
end

" Auto-commands in group to prevent re-loads
augroup VimRC
  autocmd!
  " reload .vimrc on write
  autocmd bufwritepost .vimrc source %

  " set nerdtree toggle shortcut and make open at startup
  " autocmd StdinReadPre * let s:std_in=1
  " autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif
  " autocmd VimEnter * set winfixwidth

  " Quit vim if nerdtree is only buffer open
  autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

  " set syntax for odd file extensions
  autocmd BufNewFile,BufRead .envrc set syntax=sh
  au BufNewFile,BufRead,BufReadPost Dockerfile.* set syntax=dockerfile


  " load templates when files are new
  autocmd BufNewFile *.sh 0r ~/.vim/templates/sh.tmpl
  autocmd BufNewFile *.py 0r ~/.vim/templates/python.tmpl
augroup END

