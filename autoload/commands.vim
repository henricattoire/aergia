" commands (v0.1): custom commands used by aergia.
" author: Henri Cattoire.

" AddAergiaSnippet {{{
function! commands#AddAergiaSnippet()
  let l:type = inputlist(["Select type:", "1. " . &filetype, "2. global"])
  " ask for the key used to invoke the snippet
  let l:name = input("Name of the snippet: ")
  if l:type == 2
    execute "vsplit " . g:aergia_snippets . "/" . l:name
  else
    if ! isdirectory(g:aergia_snippets . "/" . &filetype)
      execute "silent !mkdir " . g:aergia_snippets . "/" . &filetype
    endif
    execute "vsplit " . g:aergia_snippets . "/" . &filetype . "/" . &filetype . "_" . l:name
  endif
endfunction
" }}}
