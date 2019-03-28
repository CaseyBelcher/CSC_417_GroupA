autocmd BufEnter * silent! lcd %:p:h
set autoindent
set background=light
set backspace=indent,eol,start
set backupdir^=$Tmp
set ignorecase
set incsearch
set laststatus=2
set matchtime=15
set modelines=3
set mouse=a
set nocompatible
set nohlsearch
set ruler
set scrolloff=3
set showmatch
set smartcase
set splitbelow
"set syntax=on
set title
set visualbell
set number
"syntax enable
set fillchars+=vert:\ 
colorscheme torte
hi VertSplit guifg=#202020 guibg=#202020 gui=NONE ctermfg=DarkGray ctermbg=DarkGray cterm=NONE
