" aergia (v.1.3): insert snippets.
" author: Henri Cattoire.

" Callable {{{
"
" Return if it would be useful to call aergia.
function! aergia#Callable() abort
  return aergia#tags#NextTag() || !empty(aergia#snippets#Get(aergia#GetKey().key))
endfunction
" }}}
" ExpandOrJump {{{
"
" Expand key under the cursor, jump to the next tag
" or do nothing.
function! aergia#ExpandOrJump() abort
  let l:key = aergia#GetKey().key
  let l:snippet = aergia#snippets#Get(l:key)
  if !empty(l:snippet) " expand
    call aergia#InsertSnippet(l:key, copy(l:snippet))
  endif
  call aergia#tags#Jump()
endfunction
" }}}
" GetKey {{{
"
" Get a key starting at the cursor and moving backwards; Returns
" a dictionary containing the key and where it starts on the line.
function! aergia#GetKey() abort
  let l:start = col('.') - 1
  let l:line = getline('.')[:l:start]

  while l:start > 0 && l:line[l:start - 1] !~ '\s'
    let l:start -= 1
  endwhile

  return { "key": l:line[l:start:], "starts_at": l:start, }
endfunction
" }}}
" InsertSnippet {{{
"
" Insert the snippet under the cursor (preserving context and
" indentation rules set by buffer) and delete the key.
function! aergia#InsertSnippet(key, snippet) abort
  let l:context = s:ContextAroundKey(a:key)
  " add context before key if it is not empty and indent snippet where needed
  if l:context[0] !~ '^\s\+$\|^$' " before key
    let l:lines = [ l:context[0] . a:snippet[0] ] + map(a:snippet[1:], function('s:Indent'))
  else
    let l:lines = map(a:snippet, function('s:Indent'))
  endif
  " add context after key if it is not empty
  if l:context[1] !~ '^\s\+$\|^$' " after key
    let l:lines[-1] = l:lines[-1] . l:context[1]
  endif
  " delete key
  execute "normal! " . len(a:key) . "h" . len(a:key) . '"_x'
  " insert snippet
  call setline(line('.'), l:lines[0])
  call append(line('.'), l:lines[1:])
  let l:pos = getpos('.')
  call aergia#tags#command#Process()
  call setpos('.', l:pos)
endfunction
" }}}
" s:ContextAroundKey {{{
"
" Get context before and after key on the current line; Returns
" a list with two items: context before (i:0) and after (i:1) key.
function! s:ContextAroundKey(key) abort
  let l:line = getline('.')
  return [
        \ matchstr(l:line, '^\zs.*\ze' . a:key),
        \ matchstr(l:line, '^.*' . a:key . '\zs.*\ze$')
        \ ]
endfunction
" }}}
" s:Indent {{{
"
" Indent the provided line and expand tabs if needed.
function! s:Indent(_, line) abort
  let l:indented = repeat("\t", indent('.') / (&expandtab ? &shiftwidth : &tabstop)) . a:line
  if &expandtab
    let l:indented = substitute(l:indented, "\t", repeat(' ', &shiftwidth), 'g')
  endif
  return l:indented
endfunction
" }}}
