" Vim color file
"

hi clear
if exists("syntax_on")
    syntax reset
endif
let g:colors_name="imander"

if (has("termguicolors"))
  " https://stackoverflow.com/questions/62702766/termguicolors-in-vim-makes-everything-black-and-white
  let &t_8f = "\<Esc>[38:2:%lu:%lu:%lum"
  let &t_8b = "\<Esc>[48:2:%lu:%lu:%lum"
  set termguicolors
endif

hi Normal     guifg=#c6c6c6 guibg=#1F1F1F
hi Comment    guifg=#707070
hi NonText    guifg=#707070
hi Delimiter  guifg=#707070
hi LineNr     guifg=#707070
hi SpecialKey guifg=#333333
hi SignColumn guifg=bg      guibg=bg
hi VertSplit  guifg=bg      guibg=#F1FF00

" Highlight current line number
hi clear CursorLine
hi CursorLineNR guifg=#F1FF00 cterm=none

hi String       guifg=#FFE548
hi Character    guifg=#FFE548

hi Boolean      guifg=#FD8900
hi Constant     guifg=#FD8900
hi Float        guifg=#FD8900
hi Identifier   guifg=#FD8900
hi Number       guifg=#FD8900

hi Keyword      guifg=#AB59FF
hi Operator     guifg=#AB59FF
hi Repeat       guifg=#AB59FF
hi SpecialChar  guifg=#AB59FF
hi Statement    guifg=#AB59FF
hi Tag          guifg=#AB59FF
hi Conditional  guifg=#AB59FF
hi Constant     guifg=#AB59FF
hi makeCommands guifg=#AB59FF

hi Visual       guibg=#403D3D
hi Function     guifg=#50DF28
hi PreCondit    guifg=#50DF28
hi PreProc      guifg=#50DF28
hi Structure    guifg=#00CFFC
hi Typedef      guifg=#00CFFC
hi Type         guifg=#00CFFC
hi Special      guifg=#00CFFC
hi Define       guifg=#00CFFC

hi MatchParen   guifg=#000000 guibg=#FD971F
hi Todo         guifg=#FD971F guibg=bg

" Folds
hi FoldColumn  guifg=#707070 guibg=#252525
hi Folded      guifg=#707070 guibg=#252525

" File browser
hi Directory         guifg=#7b7b7b
hi NERDTreeDirSlash  guifg=#FF0000
hi NERDTreeExecFile  guifg=#38FF00
hi NERDTreeCWD       guifg=#0045FF
hi NERDTreeLinkFile  guifg=#FF00FC

" Spelling
hi SpellBad  guifg=#FF0000 cterm=underline
hi SpellCap  guifg=#E5FF00 cterm=underline

" Complete menu
hi Pmenu      guifg=#00CFFC guibg=#0d0d0d
hi PmenuSel                 guibg=#505050
hi PmenuSbar                guibg=#505050
hi PmenuThumb guifg=#00CFFC

" Error messages
hi Error    guifg=#E2D065 guibg=bg
hi ErrorMsg guifg=#FF0000 guibg=#0d0d0d

" Must be at the end, because of ctermbg=234 bug.
" https://groups.google.com/forum/#!msg/vim_dev/afPqwAFNdrU/nqh6tOM87QUJ
set background=dark
