vim9script
scriptencoding utf-8

# This is my vimrc (Vim version >= 9)
# Author: @gczcn

# Keymaps
set timeoutlen=300

g:mapleader = ' '

## Movement
noremap u gk
noremap e gj
noremap n h
noremap i l
noremap N 0
noremap I $

noremap j n
noremap J N
noremap h e
noremap H E
noremap \| ^

inoremap <M-u> <up> | cnoremap <M-u> <up>
inoremap <M-e> <down> | cnoremap <M-e> <down>
inoremap <M-n> <left> | cnoremap <M-n> <left>
inoremap <M-i> <right> | cnoremap <M-i> <right>
inoremap <slient> <M-N> :normal! 0<CR> | cnoremap <slient> <M-N> :normal! 0<CR>
inoremap <slient> <M-I> :normal! $<CR> | cnoremap <slient> <M-N> :normal! $<CR>

## Actions
noremap E J
noremap l u
noremap L U
noremap k i
noremap K I
inoremap ii <ESC>

vnoremap kr `[`]

## Windows & Splits
nnoremap <leader>ww <C-w>w
nnoremap <leader>wu <C-w>k
nnoremap <leader>we <C-w>j
nnoremap <leader>wn <C-w>h
nnoremap <leader>wi <C-w>l
nnoremap <leader>su :set nosb \| split \| set sb<CR>
nnoremap <leader>se :set sb \| split<CR>
nnoremap <leader>sn :set nospr \| vsplit \| set spr<CR>
nnoremap <leader>si :set spr \| vsplit<CR>
nnoremap <leader>sv <C-w>t<C-w>H
nnoremap <leader>sh <C-w>t<C-w>K
nnoremap <leader>srv <C-w>b<C-w>H
nnoremap <leader>srh <C-w>b<C-w>K

## Resize
nnoremap <M-U> :resize +5<CR>
nnoremap <M-E> :resize -5<CR>
nnoremap <M-N> :vertical resize -10<CR>
nnoremap <M-N> :vertical resize +10<CR>

## Copy and Paste
noremap <M-y> "+y
noremap <M-Y> "+Y
noremap <M-p> "+p
noremap <M-P> "+P
noremap <M-d> "+d
noremap <M-D> "+D

## Buffer
nnoremap <leader>bd :bd<CR>

## Other
noremap U K
nnoremap \\ :w<CR>

### Toggle background [ dark | light ]
def Toggle_background(): string
  if &background ==# 'dark'
    set background=light
  else
    set background=dark
  endif
enddef
nnoremap <F5> :call Toggle_background()<CR>

# Options
syntax enable
# colorscheme habamax

g:encoding = 'UTF-8'

set backspace=indent,eol,start
set autowrite
set breakindent
set colorcolumn=80,100
set conceallevel=2
set confirm
set copyindent
set cursorcolumn
set cursorline
set expandtab
set fileencoding=uft-8
set ignorecase
set incsearch
set linebreak
# set list
set number
set scrolloff=8
set shiftround
set shiftwidth=2
set noshowmode
set sidescrolloff=8
set smartcase
set smartindent
set smoothscroll
set softtabstop=2
set splitbelow
set splitright
set tabstop=2
set termguicolors
set undofile
set undolevels=10000
set updatetime=200
set virtualedit=block
set winminwidth=5
set nowrap

# Plugins
call plug#begin()

# List your plugins here
Plug 'altercation/vim-colors-solarized'

call plug#end()
