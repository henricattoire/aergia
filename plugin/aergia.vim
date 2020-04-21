" aergia (v.0.2): small plugin that tries to act as a snippet manager.
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
  " FindSnippet: find the path of the snippet file {{{
function! FindSnippet()
  let l:key = expand('<cword>')
  " set global snippet file
  let l:snippet_file = globpath(g:aergia_snippets, '**/' . l:key)
  " overwrite with filetype specific snippet file if it exists
  if globpath(g:aergia_snippets, '**/' . &filetype . '[_]' . l:key) != ''
    let l:snippet_file = globpath(g:aergia_snippets, '**/' . &filetype . '[_]' . l:key)
  endif

  if l:key != '' && l:snippet_file != '' && !isdirectory(l:snippet_file)
    return l:snippet_file
  endif
endfunction
  " }}}
  " ReplSnippet: replace the word under the cursor with the snippet {{{
function! ReplSnippet()
  let l:snippet_file = FindSnippet()
  if l:snippet_file != ''
    execute "normal! b" . '"_dw'
    let l:cursor = getpos('.')
    " use sed give the snippet the correct indentation
    execute "r !grep -v '^~' " . l:snippet_file
          \ . " | sed 's/\t/" . Spaces(&shiftwidth) . "/g'"
          \ . " | sed 's/^/"  . Spaces(indent(line('.'))) . "/'"
    call setpos('.', l:cursor)
    execute "normal! " . '"_dd'
    call tags#ReplCommandTags(l:snippet_file) " replace all command tags before jumping to the first tag
    call tags#NextTag()
  else
    call tags#NextTag()
  endif
endfunction
  " }}}
  " Spaces: generates a string with n spaces {{{
function! Spaces(n)
  let l:n = a:n
  let l:spaces = ""
  while l:n > 0
    let l:spaces = l:spaces . " "
    let l:n -= 1
  endwhile
  return l:spaces
endfunction
  " }}}
" }}}
" Mappings {{{
inoremap <silent> <Plug>(aergia) <esc>:call ReplSnippet()<cr>
snoremap <silent> <Plug>(aergia) <esc>:call ReplSnippet()<cr>
execute "imap " . g:aergia_key . " <Plug>(aergia)"
execute "smap " . g:aergia_key . " <Plug>(aergia)"
" }}}
" Commands {{{
command -nargs=1 AddAergiaSnippet :call commands#AddAergiaSnippet(<f-args>)
command -nargs=1 EditAergiaSnippet :call commands#EditAergiaSnippet(<f-args>)
command -nargs=1 RemoveAergiaSnippet :call commands#RemoveAergiaSnippet(<f-args>)
" }}}
