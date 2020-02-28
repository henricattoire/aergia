" aergia (v.0.1): small plugin that tries to act as a snippet manager.
" author: Henri Cattoire.

" Variables {{{
if !exists('g:aergia_snippets') 
  let g:aergia_snippets = expand('~/.vim/bundle/aergia/snippets')
endif

if !exists('g:aergia_key')
  let g:aergia_key = '<c-a>'
endif

" cannot be defined by user
let g:aergia_tag = '{+}'
" }}}
" Aergia {{{
  " TriggerAergia: find the location of the snippet file if it exists {{{
function! TriggerAergia()
  let l:key = expand('<cword>')
  " set global snippet file
  let l:snippet_file = globpath(g:aergia_snippets, '**/' . l:key)
  " overwrite with filetype specific snippet file if it exists
  if globpath(g:aergia_snippets, '**/' . &filetype . '*' . l:key) !=# ''
    let l:snippet_file = globpath(g:aergia_snippets, '**/' . &filetype . '*' . l:key)
  endif

  if l:snippet_file !=# ''
    return l:snippet_file
  else
    return "file not found"
  endif
endfunction
  " }}}
  " Aergia: replace key with corresponding snippet {{{
function! Aergia()
  let l:snippet_file = TriggerAergia()
  if l:snippet_file !=# "file not found" 
    execute "normal! b" . '"_dw'
    execute "r " . l:snippet_file
    execute "normal! k" . '"_dd'
    " keep indendation of file in mind
    let l:sf_number_of_lines = len(readfile(l:snippet_file)) - 1
    execute "normal! =" . l:sf_number_of_lines . "j"
    call SelectTag()
  else
    call SelectTag()
  endif
endfunction
  " }}}
  " SelectTag: select the next tag in the snippet {{{
function! SelectTag()
  let l:tag_pattern = '\V' .  g:aergia_tag
  try 
    execute "normal! /" .  l:tag_pattern . "\<cr>"
    execute "normal! df}"
    " append in imode on `empty` lines (do not move cursor one column back)
    if getline('.') =~ '^\s*$'
      execute "startinsert!"
    else
      execute "startinsert"
    endif
  catch /E486.*/
  endtry
endfunction
  " }}}
" }}}
" Plugin mappings {{{
inoremap <silent> <Plug>(aergia) <esc>:call Aergia()<cr>
execute "imap " . g:aergia_key . " <Plug>(aergia)"
" }}}
