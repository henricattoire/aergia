if exists("b:current_syntax")
    finish
endif

let b:current_syntax = "aergia"
" highlight tags in 'aergia' files
syntax match AergiaTag "<|+|>"
highlight link AergiaTag Keyword
syntax match AergiaSpecialTag "<|.\{-1,}|>"
highlight link AergiaSpecialTag Special
