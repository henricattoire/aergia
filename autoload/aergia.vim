" aergia (v.0.3): transform keys into snippets.
" author: Henri Cattoire.

" FindSnippet {{{
function! s:FindSnippet()
  let l:key = aergia#util#Make().base
  " look for a filetype specific snippet
  let l:file = globpath(g:aergia_snippets, '**/' . aergia#util#Type() . '[_]' . l:key)
  " fall back on global snippet if necessary
  if l:file == ''
    let l:file = globpath(g:aergia_snippets, '**/' . l:key)
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
  let l:snippet = aergia#util#Prep(readfile(a:file))
  " cursor position is one to the left if the snippet wasn't auto expanded
  execute "normal! " . (len(a:key) + (getline('.')[col('.') - 1] == a:key[-1:] ? -1 : 0)) . "h" . len(a:key) . '"_x'
  " insert snippet
  if !empty(l:snippet)
    call s:Ins(l:snippet)
  endif

  call aergia#tags#ProcessCmds() " replace all command tags before jumping to the first tag
endfunction
  " Ins {{{
function! s:Ins(snippet)
  let [l:before, l:after] = [strpart(getline('.'), 0, col('.') - 1), strpart(getline('.'), col('.') - 1)]
  let l:lnum = line('.')
  " keep text before and after the key (if any)
  if !empty(l:before) && l:before !~ '^\s\+$'
    let a:snippet[0] = l:before . (l:after == ' ' ? ' ' : '') . a:snippet[0]
  endif
  if !empty(l:after) && l:after !~ '^\s\+$'
    let a:snippet[-1] = a:snippet[-1] . l:after
  endif

  call setline(l:lnum, a:snippet[0])
  call append(l:lnum, a:snippet[1:])
endfunction
  " }}}
" }}}
