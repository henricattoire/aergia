" aergia (v.0.2): small plugin that tries to act as a snippet manager.
" author: Henri Cattoire.

" Variables {{{
if !exists('g:aergia_snippets') 
  let g:aergia_snippets = expand('~/.vim/bundle/aergia/snippets')
else
  let g:aergia_snippets = expand(g:aergia_snippets)
endif

if !exists('g:aergia_key')
  let g:aergia_key = '<c-a>'
endif

" tag start and end
let s:aergia_start_tag = '{'
let s:aergia_end_tag = '}'
" last named tag properties
let s:aergia_named_tag = ''
let s:aergia_named_tag_pos = [0, 0, 0]
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
  " ExecuteAergia: replace name with corresponding snippet {{{
function! ExecuteAergia()
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
  if s:aergia_named_tag !=# ''
    let l:cpos = getpos('.')
    call setpos('.', s:aergia_named_tag_pos)
    execute "%s/{" . s:aergia_named_tag . "}/" . expand('<cword>') . "/g"
    call setpos('.', l:cpos)
    " remove named tag
    let s:aergia_named_tag = ''
  endif
  let l:tag_pattern = s:aergia_start_tag . ".\\+" . s:aergia_end_tag
  try 
    execute "normal! /" . l:tag_pattern . "\<cr>"
    " if current tag is a named tag, store it
    if expand('<cWORD>') =~ '[A-Za-z]\+'
      let s:aergia_named_tag = expand('<cword>')
      let s:aergia_named_tag_pos = getpos('.')
    endif
    let l:append = 0
    " set append to true if the tag is the last set of chars
    if getline('.') =~ '^[^{+}]*{.\+}$'
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
inoremap <silent> <Plug>(aergia) <esc>:call ExecuteAergia()<cr>
execute "imap " . g:aergia_key . " <Plug>(aergia)"
" }}}
