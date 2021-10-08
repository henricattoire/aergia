" commands (v1.2): custom commands used by aergia.
" author: Henri Cattoire.

" AergiaAddSnippet {{{
function! aergia#commands#AergiaAddSnippet(name) abort
  if a:name =~ '^[#!A-Za-z0-9_]\+$'
    let l:options = ["Select type:", "1. global"] + map(split(&filetype, '\.'), '(v:key + 2) . ". " . v:val')
    let l:type = (len(l:options) == 2) ? 1 : inputlist(l:options)
    if l:type != 0
      let l:pick = substitute(l:options[l:type], '^\d\+\. ', '', '')
      if l:type > 1 && !isdirectory(g:aergia_snippets . "/" . l:pick)
        call mkdir(g:aergia_snippets . "/" . l:pick, "p")
      endif
      let l:path = g:aergia_snippets . "/" . (l:type > 1 ? l:pick . "/" : "") . l:pick . '_' . aergia#util#AddFt(fnameescape(a:name))
      execute "split " . l:path
    endif
  endif
endfunction
" }}}
" AergiaEditSnippet {{{
function! aergia#commands#AergiaEditSnippet(name) abort
  let l:path = s:FindFile(a:name)
  if !empty(l:path)
    execute "split " . fnameescape(l:path)
  endif
endfunction
" }}}
" AergiaRemoveSnippet {{{
function! aergia#commands#AergiaRemoveSnippet(name) abort
  let l:path = s:FindFile(a:name)
  if !empty(l:path)
    execute "call delete('" . l:path . "')"
    echo "AergiaSuccess: deleted '" . a:name . "'."
  endif
endfunction
" }}}
" FindFile {{{
function! s:FindFile(name) abort
  let l:results = globpath(g:aergia_snippets, '**/*'. aergia#util#AddFt(a:name), 0, 1)
  if len(l:results) == 0
    echoerr "AergiaWarning: you don't have a '" . a:name . "' snippet."
    return ""
  endif
  return l:results[0]
endfunction
" }}}
