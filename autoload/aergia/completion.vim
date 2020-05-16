" completion (v.0.1): completion function.
" author: Henri Cattoire.

" AergiaComplete {{{
function! aergia#completion#AergiaComplete()
  " find start of snippet and store the part of a potential snippet in base
  let l:line = getline('.')[:col('.')]
  let l:start = col('.') - 1

  while l:start > 0 && l:line[l:start - 1] =~ '[A-Za-z0-9]'
    let l:start -= 1
  endwhile

  " search for filetype and global snippets matching base
  let l:base = l:line[l:start:]
  let l:res = []
  if &filetype !=? ''
    call aergia#completion#AddItems(l:res, globpath(g:aergia_snippets, '**/' . &filetype . '[_]' . l:base . '*', 0, 1))
  endif
  call aergia#completion#AddItems(l:res, globpath(g:aergia_snippets, 'global_' . l:base . '*', 0, 1))

  call complete(l:start + 1, l:res)
  return ''
endfunction
  " AddItems {{{
function! aergia#completion#AddItems(res, items)
  let l:i = 0
  while l:i < len(a:items)
    let l:snippet = split(substitute(a:items[l:i], '.*/', '', ''), '_')
    call add(a:res, {
          \ "word": l:snippet[1],
          \ "menu": "[" . l:snippet[0] . "]",
          \ "user_data": a:items[l:i], })
    let l:i += 1
  endwhile
endfunction
" }}}
" }}}
" ListSnippets {{{
function! aergia#completion#ListSnippets(arg, line, pos)
  return s:Format('**/', a:arg)
endfunction
  " Format {{{
function! s:Format(type, filter)
  return map(filter(globpath(g:aergia_snippets, a:type . '*' . a:filter . '*', 0, 1), "!isdirectory(v:val)"),
        \ "substitute(v:val, '.*/', '', 'g')")
endfunction
  " }}}
" }}}
