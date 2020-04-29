" commands (v0.2): custom commands used by aergia.
" author: Henri Cattoire.

" AergiaAddSnippet {{{
function! commands#AergiaAddSnippet(name)
  if a:name =~ '^[A-Za-z0-9\-_.]\+'
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
            \ . (l:type == 2 ? a:name : &filetype . "/" . &filetype . "_" . a:name)
    endif
  endif
endfunction
" }}}
" AergiaEditSnippet {{{
function! commands#AergiaEditSnippet(name)
  call commands#Do(a:name, "split $")
endfunction
" }}}
" AergiaRemoveSnippet {{{
function! commands#AergiaRemoveSnippet(name)
  call commands#Do(a:name, "call delete('$')")
endfunction
" }}}
" Do {{{
function! commands#Do(name, action) abort
  let l:options = split(globpath(g:aergia_snippets, '**/*'. a:name), '\n')
  if len(l:options) == 0
    echoerr "AergiaWarning: you don't have a '" . a:name . "' snippet"
  elseif len(l:options) == 1
    execute substitute(a:action, '[$]', l:options[0], '')
  else
    let l:prompt = ["Which snippet do you want to edit/remove: "]
    let l:i = 1
    for snippet in l:options
      call add(l:prompt, i . ". " . fnamemodify(snippet, ':t'))
      let l:i += 1
    endfor
    execute substitute(a:action, '[$]', l:options[inputlist(l:prompt) - 1], '')
  endif
endfunction
" }}}
