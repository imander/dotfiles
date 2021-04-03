let g:instant_markdown_slow = 1
let g:instant_markdown_autostart = 0
let g:instant_markdown_mathjax = 1

" set syntax highlighting and folding for markdown
let g:markdown_fenced_languages = ['html', 'python', 'ruby', 'bash=sh', 'sql', 'go']

map <leader>rr :InstantMarkdownPreview<cr>
map <leader>rs :InstantMarkdownStop<cr>

