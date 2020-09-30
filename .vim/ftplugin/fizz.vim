set tabstop=4 shiftwidth=4 expandtab

augroup imander-fizz
  autocmd!
  autocmd BufWritePre * :%retab!
augroup END

