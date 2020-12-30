if exists("b:current_syntax")
    finish
endif

let b:current_syntax = "aergia"
let b:tag = '"' . get(g:aergia_tag, 'open') . '.\{-1,}' . get(g:aergia_tag, 'close') . '"'
" highlight tags in 'aergia' files
execute 'syntax match AergiaTag ' . b:tag
highlight link AergiaTag Keyword
