" commands (v0.2): custom commands used by aergia.
" author: Henri Cattoire.

" AergiaAddSnippet {{{
function! expansions#commands#AergiaAddSnippet(name)
  if a:name =~ '^[A-Za-z0-9]\+$'
    if &filetype != ''
      let l:type = inputlist(["Select type:", "1. " . &filetype, "2. global"])
    else
      let l:type = 2
    endif
    if l:type != 0
      if l:type == 1 && !isdirectory(g:aergia_snippets . "/" . &filetype)
        execute "silent !mkdir " . g:aergia_snippets . "/" . &filetype
      endif
      execute "split " . g:aergia_snippets . "/"
            \ . (l:type == 2 ? "global_" . a:name : &filetype . "/" . &filetype . "_" . a:name)
    endif
  endif
endfunction
" }}}
" AergiaEditSnippet {{{
function! expansions#commands#AergiaEditSnippet(name)
  call expansions#commands#Do(a:name, "split $")
endfunction
" }}}
" AergiaRemoveSnippet {{{
function! expansions#commands#AergiaRemoveSnippet(name)
  call expansions#commands#Do(a:name, "call delete('$')")
endfunction
" }}}
" Do {{{
function! expansions#commands#Do(name, action) abort
  let l:options = globpath(g:aergia_snippets, '**/*'. a:name, 0, 1)
  if len(l:options) == 0
    echoerr "AergiaWarning: you don't have a '" . a:name . "' snippet"
  elseif len(l:options) == 1
    execute substitute(a:action, '[$]', l:options[0], '')
  endif
endfunction
" }}}
