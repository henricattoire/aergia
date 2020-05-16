" aergia (v.0.3): transform keys into snippets.
" author: Henri Cattoire.

" Find and Replace Snippets {{{
  " FindSnippet {{{
function! s:FindSnippet()
  let l:key = aergia#util#Make().base
  " look for a filetype specific snippet
  let l:file = globpath(g:aergia_snippets, '**/' . &filetype . '[_]' . l:key)
  " fall back on global snippet if necessary
  if l:file == ''
    let l:file = globpath(g:aergia_snippets, '**/' . l:key)
  endif

  if l:key != '' && l:file != '' && !isdirectory(l:file)
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
  let l:insert = match(getline('.'), a:key . "$")
  " cursor position is one to the left if the snippet wasn't auto expanded
  execute "normal! " . (len(a:key) + (getline('.')[col('.') - 1] == a:key[-1:] ? -1 : 0)) . "h" . len(a:key) . '"_x'
  execute "normal! "
        \ . (l:insert != -1 ? "a" : "i")
        \ . join(readfile(a:file), "\n")
  " indent snippet
  execute "normal! `[=v`]"
  call aergia#tags#ProcessCmds() " replace all command tags before jumping to the first tag
endfunction
  " }}}
" }}}
