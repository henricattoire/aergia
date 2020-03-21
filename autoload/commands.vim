" commands (v0.1): custom commands used by aergia.
" author: Henri Cattoire.

" AddAergiaSnippet {{{
function! commands#AddAergiaSnippet(name)
  " the key (read: name) to invoke the snippet can not contain spaces or tabs
  if a:name =~ '[ \t]'
    echoerr "AergiaError: snippet name can not contain spaces or tabs"
  else
    let l:type = inputlist(["Select type:", "1. " . &filetype, "2. global"])
    if l:type == 2
      execute "vsplit " . g:aergia_snippets . "/" . a:name
    else
      if ! isdirectory(g:aergia_snippets . "/" . &filetype)
        execute "silent !mkdir " . g:aergia_snippets . "/" . &filetype
      endif
      execute "vsplit " . g:aergia_snippets . "/" . &filetype . "/" . &filetype . "_" . a:name
    endif
  endif
endfunction
" }}}
