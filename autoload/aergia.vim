" aergia (v.0.3): transform keys into snippets.
" author: Henri Cattoire.

" Find and Replace Snippets {{{
  " FindSnippet {{{
function! s:FindSnippet()
  let l:key = expand('<cword>')
  " look for a filetype specific snippet
  let l:file = globpath(g:aergia_snippets, '**/' . &filetype . '[_]' . l:key)
  " fall back on global snippet if necessary
  if l:file == ''
    let l:file = globpath(g:aergia_snippets, '**/' . l:key)
  endif

  if l:key != '' && l:file != '' && !isdirectory(l:file)
    return l:file
  endif
endfunction
  " }}}
  " ReplSnippet {{{
function! aergia#ReplSnippet()
  let l:file = s:FindSnippet()
  if l:file != ''
    call aergia#IncludeFile(l:file)
  endif
  call aergia#tags#JumpTag()
endfunction
  " }}}
  " IncludeFile {{{
function! aergia#IncludeFile(file)
  let l:insert = match(getline('.'), expand('<cword>') . "$")
  execute "normal! b" . '"_dw'
  execute "normal! "
        \ . (l:insert != -1 ? "a" : "i")
        \ . join(readfile(a:file), "\n")
  " indent snippet
  execute "normal! `[=v`]"
  call aergia#tags#ProcessCmds() " replace all command tags before jumping to the first tag
endfunction
  " }}}
" }}}
