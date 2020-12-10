syntax off
set nohlsearch
set mouse=
set ttymouse=
filetype indent plugin on

" add yaml config
au! BufNewFile,BufReadPost *.{yaml,yml} set filetype=yaml
autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab
