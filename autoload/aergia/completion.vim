" completion (v.1.1): completion functions.
" author: Henri Cattoire.

" AergiaComplete {{{
function! aergia#completion#AergiaComplete()
  let l:bit = aergia#util#Make()
  let l:res = []
  if !empty(&filetype)
    call aergia#completion#AddItems(l:res,
          \ globpath(g:aergia_snippets, '**/' . aergia#util#Type() . '[_]' . l:bit.base . '*', 0, 1))
  endif
  call aergia#completion#AddItems(l:res,
        \ globpath(g:aergia_snippets, 'global_' . l:bit.base . '*', 0, 1))

  call complete(l:bit.start + 1, l:res)
  return ''
endfunction
  " AddItems {{{
function! aergia#completion#AddItems(res, items)
  let l:i = 0
  while l:i < len(a:items)
    let l:snippet = split(substitute(a:items[l:i], '.*/', '', ''), '_')
    call add(a:res, {
          \ "word": l:snippet[1],
          \ "kind": "[s]",
          \ "menu": "[" . l:snippet[0] . "]",
          \ "dup": 1,
          \ "user_data": a:items[l:i], })
    let l:i += 1
  endwhile
endfunction
  " }}}
" }}}
" AergiaExpand {{{
function! aergia#completion#AergiaExpand(item)
  " ensure that the item isn't empty and is indeed a snippet
  if empty(a:item) || get(a:item, "kind") !~ "s"
    return
  endif
  call aergia#IncludeFile(a:item.word, a:item.user_data)
  " simulate first jump
  execute 'call feedkeys("\' . g:aergia_key . '")'
endfunction
" }}}
" ListSnippets {{{
function! aergia#completion#ListSnippets(arg, line, pos)
  return map(uniq(filter(globpath(g:aergia_snippets, '**/*' . a:arg . '*', 0, 1), "filereadable(v:val)")),
        \ "substitute(v:val, '.*/', '', 'g')")
endfunction
" }}}
