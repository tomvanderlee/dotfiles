execute pathogen#infect()

syntax on
filetype plugin indent on

set number
set background=dark
set hlsearch
set listchars=trail:·,tab:▸\ ,eol:¬
set list
set foldmethod=indent

autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTreeType") && b:NERDTreeType == "primary") | q | endif
