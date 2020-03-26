" commands (v0.1): custom commands used by aergia.
" author: Henri Cattoire.

" AddAergiaSnippet: add a snippet interactively {{{
function! commands#AddAergiaSnippet(name)
  " the key (read: name) to invoke the snippet can not contain spaces or tabs
  if a:name =~ '[ \t]'
    echoerr "AergiaError: snippet name can not contain spaces or tabs"
  else
    if &filetype
      let l:type = inputlist(["Select type:", "1. " . &filetype, "2. global"])
    else
      let l:type = 2
    endif
    if l:type == 2
      execute "vsplit " . g:aergia_snippets . "/" . a:name
    else
      if !isdirectory(g:aergia_snippets . "/" . &filetype)
        execute "silent !mkdir " . g:aergia_snippets . "/" . &filetype
      endif
      execute "vsplit " . g:aergia_snippets . "/" . &filetype . "/" . &filetype . "_" . a:name
    endif
  endif
endfunction
" }}}
" EditAergiaSnippet: edit a snippet interactively {{{
function! commands#EditAergiaSnippet(name)
  call commands#SnippetState(a:name, "vsplit")
endfunction
" }}}
" RemoveAergiaSnippet: remove a snippet interactively {{{
function! commands#RemoveAergiaSnippet(name)
  call commands#SnippetState(a:name, "silent! !rm")
endfunction
" }}}
" SnippetState: helper to edit/remove a snippet {{{
function! commands#SnippetState(name, action)
  let l:options = split(globpath(g:aergia_snippets, '**/*'. a:name), '\n')
  if len(l:options) == 0
    echom "AergiaWarning: you don't have a '" . a:name . "' snippet"
  elseif len(l:options) == 1
    execute a:action . " " . l:options[0]
  else
    let l:list = ["Which snippet do you want to edit/remove: "]
    let l:i = 1
    for snippet in l:options
      call add(l:list, i . ". " . fnamemodify(snippet, ':t'))
      let l:i += 1
    endfor
    let l:chosen = inputlist(l:list)
    execute a:action . " " . l:options[l:chosen - 1]
  endif
endfunction
" }}}
