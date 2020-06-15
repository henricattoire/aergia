" aergia (v.1.1): transform keys into snippets.
" author: Henri Cattoire.

" FindSnippet {{{
function! aergia#FindSnippet()
  let l:key = aergia#util#Make().base
  " look for a filetype specific snippet
  let l:file = globpath(g:aergia_snippets, '**/' . aergia#util#Type() . '[_]' . l:key)
  " fall back on global snippet if necessary
  if empty(l:file)
    let l:file = globpath(g:aergia_snippets, '**/global_' . l:key)
  endif

  if !empty(l:key) && filereadable(l:file)
    let s:info = { "key": l:key, "file" : l:file, }
    return 1
  endif
endfunction
" }}}
" ReplSnippet {{{
function! aergia#ReplSnippet()
  if aergia#FindSnippet()
    call aergia#IncludeFile(s:info.key, s:info.file)
  endif
  call aergia#tags#JumpTag()
endfunction
" }}}
" IncludeFile {{{
function! aergia#IncludeFile(key, file)
  let l:curline = getline('.')
  " preserve real characters before and after key
  let [l:before, l:after] = [matchstr(l:curline, '^\zs.*\ze' . a:key), matchstr(l:curline, '^.*' . a:key . '\zs.*\ze$')]
  " prepare snippet to be inserted and remove key
  let l:snippet = aergia#util#Prep(readfile(a:file), !empty(l:before) && l:before !~ '^\s\+$')
  execute "normal! " . (len(a:key) + (l:curline[col('.') - 1] == a:key[-1:] ? -1 : 0)) . "h" . len(a:key) . '"_x'
  " insert snippet
  if !empty(l:snippet)
    call s:Ins(l:snippet, l:before, l:after)
    call aergia#tags#ProcessCmds() " replace all command tags before jumping to the first tag
  endif
endfunction
  " Ins {{{
function! s:Ins(snippet, before, after)
  " keep text before and after the key (if any)
  if !empty(a:before) && a:before !~ '^\s\+$'
    let a:snippet[0] = a:before . a:snippet[0]
  endif
  if !empty(a:after) && a:after !~ '^\s\+$'
    let a:snippet[-1] = a:snippet[-1] . a:after
  endif

  let l:lnum = line('.')
  call setline(l:lnum, a:snippet[0])
  call append(l:lnum, a:snippet[1:])
endfunction
  " }}}
" }}}
