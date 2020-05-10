" util (v.0.1): utility functions.
" author: Henri Cattoire.

" Wrap {{{
function! util#Wrap(s)
  " make string safe to be used in a regex, wrap each char in brackets
  return substitute(a:s, '.', { m -> '[' . m[0] . ']' }, 'g')
endfunction
" }}}
" List {{{
function! util#List(arg, line, pos)
  return util#Format('**/', a:arg)
endfunction
" }}}
" Format {{{
function! util#Format(type, filter)
  return map(filter(globpath(g:aergia_snippets, a:type . '*' . a:filter . '*', 0, 1), "!isdirectory(v:val)"),
        \ "substitute(v:val, '.*/', '', 'g')")
endfunction
" }}}
