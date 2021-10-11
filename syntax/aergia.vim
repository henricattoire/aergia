if exists("b:current_syntax")
    finish
endif

let b:current_syntax = "aergia"
" highlight tags in 'aergia' files
syntax match AergiaTag "<|.\{-1,}|>"
highlight link AergiaTag Keyword
