" aergia (v.1.3): get snippets.
" author: Henri Cattoire.

let s:cache = {}
" Get {{{
"
" Get the snippet of the first filetype that has a snippet
" for the provided key and body (or nothing; empty list).
function! aergia#snippets#Get(key) abort
  for l:ft in split(&filetype, '\.') + [ "global" ]
    let l:snippets = s:GetSnippets(l:ft)
    if has_key(l:snippets, a:key)
      return l:snippets[a:key]
    endif
  endfor
  return []
endfunction
" }}}
" GetAll {{{
"
" Get all snippets matching the provided filter (just a [partial]
" key) and group them per filetype in a dictionary. It will match
" keys that begin with the filter.
function! aergia#snippets#GetAll(filter) abort
  let l:snippets = {}
  for l:ft in split(&filetype, '\.') + [ "global" ]
    let l:snippets[l:ft] = filter(s:GetSnippets(l:ft), 'v:key =~ "^' . a:filter . '"')
  endfor
  return l:snippets
endfunction
" }}}
" s:GetSnippets {{{
"
" Get snippets for the provided filetype from cache or disk (if needed).
function! s:GetSnippets(ft) abort
  if g:aergia_cache
    if !has_key(s:cache, a:ft)
      let s:cache[a:ft] = s:LoadSnippets(a:ft)
    endif
    return s:cache[a:ft]
  else
    return s:LoadSnippets(a:ft)
  endif
endfunction
" }}}
" s:LoadSnippets {{{
"
" Load snippets from disk for the provided filetype (or nothing; empty dictionary).
function! s:LoadSnippets(ft) abort
  let l:filename = g:aergia_snippets . "/" . a:ft . ".json"
  return filereadable(l:filename) ? json_decode(join(readfile(l:filename))) : {}
endfunction
" }}}
