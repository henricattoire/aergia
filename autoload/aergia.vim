" aergia (v.0.3): transform keys into snippets.
" author: Henri Cattoire.

" FindSnippet {{{
function! s:FindSnippet()
  let l:key = aergia#util#Make().base
  " look for a filetype specific snippet
  let l:file = globpath(g:aergia_snippets, '**/' . aergia#util#Type() . '[_]' . l:key)
  " fall back on global snippet if necessary
  if empty(l:file)
    let l:file = globpath(g:aergia_snippets, '**/global_' . l:key)
  endif

  if !empty(l:key) && filereadable(l:file)
    return { "key": l:key, "file" : l:file, }
  endif
endfunction
" }}}
" ReplSnippet {{{
function! aergia#ReplSnippet()
  let l:info = s:FindSnippet()
  if !empty(l:info)
    call aergia#IncludeFile(l:info.key, l:info.file)
  endif
  call aergia#tags#JumpTag()
endfunction
" }}}
" IncludeFile {{{
function! aergia#IncludeFile(key, file)
  let l:curline = getline('.')
  " obtain part before and after the key
  let [l:before, l:after] = [matchstr(l:curline, '^\zs.*\ze' . a:key), matchstr(l:curline, '^.*' . a:key . '\zs.*\ze$')]
  " prepare snippet to be inserted
  let l:snippet = aergia#util#Prep(readfile(a:file), !empty(l:before) && l:before !~ '^\s\+$')
  " remove key (one char less if the snippet wasn't auto expanded)
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
