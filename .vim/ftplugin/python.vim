let g:black_virtualenv="~/.black/venv"

augroup imander-python
  " run Black autoformatting on save
  autocmd BufWritePre *.py silent! execute ':Black'
augroup END

nnoremap <leader>ll :call flake8#Flake8()<CR>
