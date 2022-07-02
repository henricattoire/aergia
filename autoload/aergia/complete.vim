" complete (v.1.3): complete keys
" author: Henri Cattoire.

" AergiaComplete {{{
"
" Try to autocomplete key under the cursor; See
" docs for usage.
function! aergia#complete#AergiaComplete() abort
  let l:key = aergia#GetKey()
  call complete(l:key.starts_at + 1, s:CreateCompletionItems(aergia#snippets#GetAll(l:key.key)))
  return ''
endfunction
" }}}
" s:CreateCompletionItems {{{
"
" Create completion items from a dictionary of dictionaries.
function! s:CreateCompletionItems(dict) abort
  let l:items = []
  for l:ft in keys(a:dict)
    for l:key in keys(a:dict[l:ft])
      call add(l:items, {
            \ "word": l:key,
            \ "kind": "[snippet]",
            \ "menu": "[" . l:ft . "]",
            \ "dup": 1, })
            " Note: storing the snippet as user_data
            "       introduced annoying bugs in the
            "       (auto)expand option and is not much
            "       faster because caching already
            "       happens in the snippets module.
    endfor
  endfor
  return l:items
endfunction
" }}}
" ExpandCompletedItem {{{
"
" Expand the given completed item as a snippet if it is one.
function! aergia#complete#ExpandCompletedItem(item) abort
  if empty(a:item) || a:item.kind != "[snippet]"
    return
  endif
  execute 'call feedkeys("\' . g:aergia_trigger . '")'
endfunction
" }}}
