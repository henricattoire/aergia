" util (v.0.1): utility functions.
" author: Henri Cattoire.

" Wrap {{{
function! aergia#util#Wrap(s)
  " make string safe to be used in a regex, wrap each char in brackets
  return substitute(a:s, '.', { m -> '[' . m[0] . ']' }, 'g')
endfunction
" }}}
" Type {{{
function! aergia#util#Type()
  return '\(' . join(split(&filetype, '\.'), '\|') . '\)'
endfunction
" }}}
" Make {{{
function! aergia#util#Make()
  " construct the potential identifier from cursor position
  let l:line = getline('.')[:col('.') - 1]
  let l:start = col('.') - 1

  " (IM): support more than just alphanumeric characters
  while l:start > 0 && l:line[l:start - 1] =~ '[A-Za-z0-9]'
    let l:start -= 1
  endwhile

  return { "base": l:line[l:start:], "start": l:start, }
endfunction
" }}}
" Prep {{{
function! aergia#util#Prep(snippet)
  return map(a:snippet, function('s:Space'))
endfunction
  " Space {{{
function! s:Space(k, s)
  " a sane version, at least for inserting snippets, of '=' in normal mode
  return repeat(' ', indent('.')) . substitute(a:s, "\t", repeat(' ', shiftwidth()), "g")
endfunction
  " }}}
" }}}
