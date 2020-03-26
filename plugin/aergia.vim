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

  if l:snippet_file != ''
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
    let l:indent = IndentSnippet()
    " use sed to prefix the snippet with the correct indentation
    execute "r !grep -v '^~' " . l:snippet_file . " | sed 's/^/" . l:indent . "/g'"
    call setpos('.', l:cursor)
    execute "normal! " . '"_dd'
    call tags#ReplCommandTags(l:snippet_file) " replace all command tags before jumping to the first tag
    call tags#NextTag()
  else
    call tags#NextTag()
  endif
endfunction
  " }}}
  " IndentSnippet: indent the snippet (using spaces) {{{
function! IndentSnippet()
  " keep indendation of file in mind
  let l:indent_level = indent(line('.'))
  let l:indent = ""
  while l:indent_level > 0
    let l:indent = l:indent . " "
    let l:indent_level -= 1
  endwhile
  return l:indent
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
