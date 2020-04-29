" util (v.0.1): utility functions.
" author: Henri Cattoire.

" GetCount {{{
function! util#GetCount(pattern)
  let l:count = 0
  silent! execute '%s/' . a:pattern . '/\=execute(''let l:count += 1'')/gn'
  return l:count
endfunction
" }}}
" Wrap {{{
function! util#Wrap(s)
  " make string safe to be used in a regex, wrap each char in brackets
  let l:wrapped = substitute(a:s, '.', { m -> '[' . m[0] . ']' }, 'g')
  return l:wrapped
endfunction
" }}}
"
