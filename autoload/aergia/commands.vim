" commands (v0.1): custom commands used by aergia.
" author: Henri Cattoire.

" AergiaAddSnippet {{{
function! aergia#commands#AergiaAddSnippet(name)
  " (IM): support more than just alphanumeric characters
  if a:name =~ '^[A-Za-z0-9]\+$'
    let l:options = ["Select type:", "1. global"] + map(split(&filetype, '\.'), {i, val -> (i + 2) . ". " . val})
    if len(l:options) == 2
      let l:type = 1
    else
      let l:type = inputlist(l:options)
    endif
    if l:type != 0
      let l:option = substitute(l:options[l:type], '^\d\+\. ', '', '')
      if l:type > 1 && !isdirectory(g:aergia_snippets . "/" . l:option)
        call system('mkdir ' . g:aergia_snippets . "/" . l:option)
      endif
      execute "split " . g:aergia_snippets . "/"
            \ . (l:type > 1 ? l:option . "/" : "") . l:option . '_' . a:name
    endif
  endif
endfunction
" }}}
" AergiaEditSnippet {{{
function! aergia#commands#AergiaEditSnippet(name)
  call s:Do(a:name, "split $")
endfunction
" }}}
" AergiaRemoveSnippet {{{
function! aergia#commands#AergiaRemoveSnippet(name)
  call s:Do(a:name, "call delete('$')")
endfunction
" }}}
" Do {{{
function! s:Do(name, action) abort
  let l:options = globpath(g:aergia_snippets, '**/*'. a:name, 0, 1)
  if len(l:options) == 0
    echoerr "AergiaWarning: you don't have a '" . a:name . "' snippet"
  elseif len(l:options) == 1
    execute substitute(a:action, '[$]', l:options[0], '')
  endif
endfunction
" }}}
