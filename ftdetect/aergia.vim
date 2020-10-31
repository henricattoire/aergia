" assuming every file under 'g:aergia_snippets' is a snippet
au BufNewFile,BufRead * if expand('%:p') =~ '^' . g:aergia_snippets | set filetype=aergia | endif
