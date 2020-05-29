let g:black_virtualenv="~/.black/venv"

" run Black autoformatting on save
autocmd BufWritePre *.py silent! execute ':Black'

nnoremap <leader>ll :call flake8#Flake8()<CR>
