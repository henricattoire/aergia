" completion (v.1.1): completion functions.
" author: Henri Cattoire.

" AergiaComplete {{{
function! aergia#completion#AergiaComplete() abort
  let l:key = aergia#util#Key()
  let l:res = []
  if !empty(&filetype)
    call aergia#completion#AddItems(l:res,
          \ globpath(g:aergia_snippets, '**/' . aergia#util#Type() . '[_]' . l:key.base . '*', 0, 1))
  endif
  call aergia#completion#AddItems(l:res,
        \ globpath(g:aergia_snippets, 'global[_]' . l:key.base . '*', 0, 1))

  call complete(l:key.start + 1, l:res)
  return ''
endfunction
  " AddItems {{{
function! aergia#completion#AddItems(res, items) abort
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
function! aergia#completion#AergiaExpand(item) abort
  " react if the item is really an aergia snippet
  if empty(a:item) || get(a:item, "kind") != "[s]"
    return
  endif
  call aergia#Insert({"key": a:item.word, "path": a:item.user_data,})
  " simulate the first jump
  execute 'call feedkeys("\' . g:aergia_trigger . '")'
endfunction
" }}}
" ListSnippets {{{
function! aergia#completion#ListSnippets(arg, line, pos) abort
  return map(filter(
        \ globpath(g:aergia_snippets, '**/*' . a:arg . (empty(a:arg) ? '' : '*'), 0, 1),
        \ "filereadable(v:val)"), "fnamemodify(v:val, ':t')")
endfunction
" }}}
