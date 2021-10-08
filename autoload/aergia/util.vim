" util (v.1.2): utility functions.
" author: Henri Cattoire.

" Key {{{
function! aergia#util#Key() abort
  " construct key starting from cursor
  let l:start = col('.') - 1
  let l:line = getline('.')[:l:start]

  while l:start > 0 && l:line[l:start - 1] =~ '[#!A-Za-z0-9_]'
    let l:start -= 1
  endwhile

  return { "base": escape(l:line[l:start:], '{}'), "start": l:start, }
endfunction
" }}}
" AddFt {{{
function! aergia#util#AddFt(file) abort
  return a:file . ".ae"
endfunction
" }}}
" Type {{{
function! aergia#util#Type() abort
  " put filetype(s) in regex format
  return '\(' . join(split(&filetype, '\.'), '\|') . '\)'
endfunction
" }}}
" PathComp {{{
function aergia#util#PathComp(path1, path2)
  let l:a = 0
  let l:b = 0
  " try to match first filetype in path
  let l:types = split(&ft, '\.')
  let l:i = len(l:types) - 1
  while l:i > -1
    let l:cur = get(l:types, i)
    if a:path1 =~ l:cur . '/' . l:cur
      let l:a = i
    endif
    if a:path2 =~ l:cur . '/' . l:cur
      let l:b = i
    endif
    let l:i -= 1
  endwhile
  return l:a - l:b
endfunction
" }}}
" Context {{{
function! aergia#util#Context(key) abort
  let l:line = getline('.')
  " get context around a given key(word)
  let l:ahead = matchstr(l:line, '^\zs.*\ze' . a:key)
  let l:after = matchstr(l:line, '^.*' . a:key . '\zs.*\ze$')
  return {
        \ 'ahead': [ l:ahead !~ '^\s\+$\|^$', l:ahead ],
        \ 'after': [ l:after !~ '^\s\+$\|^$', l:after ],
        \ }
endfunction
" }}}
" Indent {{{
function! aergia#util#Indent(not_first, i, line) abort
  if a:i == 0 && a:not_first
    return a:line
  endif

  let l:line = a:line
  if &expandtab
    let l:line = substitute(l:line, "\t", s:GetIndent(), 'g')
  endif
  return repeat(s:GetIndent(), indent('.') / (&shiftwidth ? &shiftwidth : &tabstop)) . l:line
endfunction
  " GetIndent {{{
function! s:GetIndent() abort
  " see https://github.com/hrsh7th/vim-vsnip/blob/master/autoload/vsnip/indent.vim#L5
  return !&expandtab ? "\t" : repeat(' ', &shiftwidth ? &shiftwidth : &tabstop)
endfunction
  " }}}
" }}}
