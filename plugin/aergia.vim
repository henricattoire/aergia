" aergia (v.0.3): small plugin that tries to act as a snippet manager.
" author: Henri Cattoire.

" Global Variables {{{
if !exists('g:aergia_snippets')
  let g:aergia_snippets = expand('~/.vim/bundle/aergia/snippets')
else
  let g:aergia_snippets = expand(g:aergia_snippets)
endif

if !exists('g:aergia_key')
  let g:aergia_key = '<c-a>'
endif
" }}}
" Find and Replace Snippets {{{
  " FindSnippet {{{
function! FindSnippet()
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
function! ReplSnippet()
  let l:file = FindSnippet()
  if l:file != ''
    let l:insert = match(getline('.'), expand('<cword>') . "$")
    execute "normal! b" . '"_dw'
    execute "normal! "
          \ . (l:insert != -1 ? "a" : "i")
          \ . join(readfile(l:file), "\n")
    " indent snippet
    execute "normal! `[=v`]"
    call tags#ProcessCmds() " replace all command tags before jumping to the first tag
    call tags#JumpTag()
  else
    call tags#JumpTag()
  endif
endfunction
  " }}}
" }}}
" Mappings {{{
inoremap <silent> <Plug>(aergia) <esc>:call ReplSnippet()<cr>
snoremap <silent> <Plug>(aergia) <esc>:call ReplSnippet()<cr>
execute "imap " . g:aergia_key . " <Plug>(aergia)"
execute "smap " . g:aergia_key . " <Plug>(aergia)"
inoremap <C-x><C-m> <C-r>=completion#AergiaComplete()<CR>
" }}}
" Commands {{{
command -nargs=1 AergiaAddSnippet :call commands#AergiaAddSnippet(<f-args>)
command -nargs=1 AergiaEditSnippet :call commands#AergiaEditSnippet(<f-args>)
command -nargs=1 AergiaRemoveSnippet :call commands#AergiaRemoveSnippet(<f-args>)
" }}}
