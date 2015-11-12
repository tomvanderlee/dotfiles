silent! execute pathogen#infect()

""" DEFAULT VIM SETTINGS

" Reload vimrc on save
augroup reload_vimrc " {
    autocmd!
    autocmd BufWritePost $MYVIMRC source $MYVIMRC
augroup END " }

let mapleader=" "

syntax on
filetype plugin indent on

" Set colorscheme when the terminal has 256 color support
try
    if (&t_Co == 256) && match($TERM, "256color") >= 0
        colorscheme Benokai
    else
        throw "nocolor"
    endif
catch
    colorscheme desert
endtry

" Some vim settings
set number
set relativenumber
set hlsearch
set list
set modeline
set background=dark
set foldmethod=indent
set listchars=trail:·,tab:▸\ ,eol:¬
set scrolloff=1
set backspace=indent,eol,start
set cursorline

" Disable ex mode
nnoremap Q <Nop>

" Save as sudo
cnoremap w!! w !sudo tee > /dev/null %

" Switch windows with <C-W>[direction]
nnoremap <C-J> <C-W>j
nnoremap <C-K> <C-W>k
nnoremap <C-H> <C-W>h
nnoremap <C-L> <C-W>l

" Never use the arrow keys
noremap  <Up> ""
noremap! <Up> <Esc>
noremap  <Down> ""
noremap! <Down> <Esc>
noremap  <Left> ""
noremap! <Left> <Esc>
noremap  <Right> ""
noremap! <Right> <Esc>

" Append modeline when pressing <leader> ml
function! AppendModeline()
    let l:modeline = printf(" vim: set ts=%d sw=%d tw=%d %set :",
        \ &tabstop, &shiftwidth, &textwidth, &expandtab ? '' : 'no')
    let l:modeline = substitute(&commentstring, "%s", l:modeline, "")
    call append(line("$"), l:modeline)
endfunction
nnoremap <silent> <Leader>ml :call AppendModeline()<CR>

" NeoVIM specifics
if has('nvim')
    nmap <BS> <C-W>h
    tnoremap <Esc> <C-\><C-n>
endif

""" PLUGIN SPECIFIC SETTINGS

if exists("g:loaded_pathogen")

    " NERDTree:
    " Open NERDTree when no file is specified
    autocmd StdinReadPre * let s:std_in=1
    autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif
    autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTreeType") && b:NERDTreeType == "primary") | q | endif

    " Airline:
    " On arch linux install the following:
    " otf-powerline-symbols-git
    " powerline-fonts-git
    let g:airline_powerline_fonts = 1
    if !exists('g:airline_symbols')
        let g:airline_symbols = {}
    endif
    let g:airline_symbols.space = "\ua0"
    set laststatus=2

endif

" vim: set ts=4 sw=4 tw=4 et :
