" aergia (v.1.1): transform keys into snippets.
" author: Henri Cattoire.

" FindSnippet {{{
function! aergia#FindSnippet() abort
  " do not run this function needlessly
  if exists('s:info')
    return 1
  endif

  let l:key = aergia#util#Make().base
  if !empty(l:key)
    " look for a filetype specific snippet
    let l:file = globpath(g:aergia_snippets, '**/' . aergia#util#Type() . '[_]' . l:key)
    " fall back on global snippet if necessary
    if empty(l:file)
      let l:file = globpath(g:aergia_snippets, '**/global_' . l:key)
    endif

    if filereadable(l:file)
      let s:info = { "key": l:key, "file": l:file, }
      return 1
    endif
  endif
endfunction
" }}}
" ReplSnippet {{{
function! aergia#ReplSnippet() abort
  if aergia#FindSnippet()
    call aergia#IncludeFile(s:info.key, s:info.file)
    unlet s:info
  endif
  call aergia#tags#JumpTag()
endfunction
" }}}
" IncludeFile {{{
function! aergia#IncludeFile(key, file) abort
  let l:line = getline('.')
  " preserve real characters before and after key
  let l:before = {
        \ "text": matchstr(l:line, '^\zs.*\ze' . a:key), }
  let l:behind = {
        \ "text": matchstr(l:line, '^.*' . a:key . '\zs.*\ze$'), }
  let l:before.valid = !empty(l:before.text) && l:before.text !~ '^\s\+$'
  let l:behind.valid = !empty(l:behind.text) && l:behind.text !~ '^\s\+$'
  " prepare snippet to be inserted and remove key
  let l:snippet = aergia#util#Prep(readfile(a:file), l:before.valid)
  execute "normal! " . (len(a:key) + (l:line[col('.') - 1] == a:key[-1:] ? -1 : 0)) . "h" . len(a:key) . '"_x'
  " insert snippet
  if !empty(l:snippet)
    call s:Ins(l:snippet, l:before, l:behind)
    call aergia#tags#ProcessCmds() " replace command tags before jumping
  endif
endfunction
  " Ins {{{
function! s:Ins(snippet, before, behind) abort
  " keep text before and after the key (if any)
  if a:before.valid
    let a:snippet[0] = a:before.text . a:snippet[0]
  endif
  if a:behind.valid
    let a:snippet[-1] = a:snippet[-1] . a:behind.text
  endif

  let l:num = line('.')
  call setline(l:num, a:snippet[0])
  call append(l:num, a:snippet[1:])
endfunction
  " }}}
" }}}
