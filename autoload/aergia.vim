" aergia (v.1.2): transform keys into snippets.
" author: Henri Cattoire.

" Useful {{{
function! aergia#Useful() abort
  return aergia#tags#CanJump() || !empty(aergia#Snippet())
endfunction
" }}}
" Respond {{{
function! aergia#Respond() abort
  let l:snippet = aergia#Snippet()
  if !empty(l:snippet)
    call aergia#Insert(l:snippet)
  endif
  call aergia#tags#Jump()
endfunction
" }}}
" Snippet {{{
function! aergia#Snippet() abort
  let l:snippet = {}

  let l:key = aergia#util#Key().base
  if !empty(l:key)
    let l:path = globpath(g:aergia_snippets, '**/' . aergia#util#Type() . '[_]' . l:key, 0, 1)
    " fall back on global snippets if necessary
    if empty(l:path)
      let l:path = globpath(g:aergia_snippets, '**/global_' . l:key, 0, 1)
    endif

    if !empty(l:path)
      " just take the first path from the list
      let l:snippet = { "key": l:key, "path": get(sort(l:path, 'aergia#util#PathComp'), 0), }
    endif
  endif
  return l:snippet
endfunction
" }}}
" Insert {{{
function! aergia#Insert(snippet) abort
  let l:context = aergia#util#Context(a:snippet.key)
  " get content of snippet and remove key
  let l:content = map(readfile(a:snippet.path), function('aergia#util#Indent', [ l:context.ahead[0] ]))
  execute "normal! " . len(a:snippet.key) . "h" . len(a:snippet.key) . '"_x'

  if l:context.ahead[0]
    let l:content[0] = l:context.ahead[1] . l:content[0]
  endif
  if l:context.after[0]
    let l:content[-1] = l:content[-1] . l:context.after[1]
  endif
  call setline(line('.'), l:content[0])
  call append(line('.'), l:content[1:])
  call aergia#tags#ProcessCommands()
endfunction
" }}}
