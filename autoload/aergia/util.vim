" util (v.0.1): utility functions.
" author: Henri Cattoire.

" Wrap {{{
function! aergia#util#Wrap(s)
  " make string safe to be used in a regex, wrap each char in brackets
  return substitute(a:s, '.', { m -> '[' . m[0] . ']' }, 'g')
endfunction
" }}}
