" aergia (v.0.1): small plugin that tries to act as a snippet manager.
" author: Henri Cattoire.

" Variables {{{
if !exists('g:aergia_snippets') 
  let g:aergia_snippets = expand('~/.vim/bundle/aergia/snippets')
endif

if !exists('g:aergia_key')
  let g:aergia_key = '<c-a>'
endif

let s:aergia_tag = '{+}'
" }}}
" Functions {{{
  " TriggerAergia: find the path of the snippet file {{{
function! TriggerAergia()
  let l:key = expand('<cword>')
  " set global snippet file
  let l:snippet_file = globpath(g:aergia_snippets, '**/' . l:key)
  " overwrite with filetype specific snippet file if it exists
  if globpath(g:aergia_snippets, '**/' . &filetype . '?' . l:key) !=# ''
    let l:snippet_file = globpath(g:aergia_snippets, '**/' . &filetype . '*' . l:key)
  endif

  if l:snippet_file !=# '' && l:key !=# ''
    return l:snippet_file
  else
    return "file not found"
  endif
endfunction
  " }}}
  " Aergia: replace name with corresponding snippet {{{
function! Aergia()
  let l:snippet_file = TriggerAergia()
  if l:snippet_file !=# "file not found" 
    execute "normal! b" . '"_dw'
    let l:cursor = getpos('.')
    " keep indendation of file in mind
    let l:indent_level = indent(line('.'))
    let l:indent = ""
    while l:indent_level > 0
      let l:indent = l:indent . " "
      let l:indent_level -= 1
    endwhile
    " use sed to prefix the snippet with the correct indentation
    execute "r !cat " . l:snippet_file . "| sed 's/^/" . l:indent . "/g'"
    call setpos('.', l:cursor)
    execute "normal! " . '"_dd'
    call SelectTag()
  else
    call SelectTag()
  endif
endfunction
  " }}}
  " SelectTag: select the next tag in the snippet {{{
function! SelectTag()
  let l:tag_pattern = '\V' .  s:aergia_tag
  try 
    execute "normal! /" .  l:tag_pattern . "\<cr>"
    let l:append = 0
    " set append to true if the tag is the last set of chars
    if getline('.') =~ '^[^{+}]*{+}$'
      let l:append = 1
    endif
    execute "normal! df}"
    " append in imode on `empty` lines (do not move cursor one column back)
    if l:append == 0
      execute "startinsert"
    else
      execute "startinsert!"
    endif
  catch /E486.*/
    echom "AegriaError: found no tag/snippet"
  endtry
endfunction
  " }}}
" }}}
" Mappings {{{
inoremap <silent> <Plug>(aergia) <esc>:call Aergia()<cr>
execute "imap " . g:aergia_key . " <Plug>(aergia)"
" }}}
