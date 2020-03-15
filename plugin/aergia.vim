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
  " Main {{{
    " FindSnippet: find the path of the snippet file {{{
function! FindSnippet()
  let l:key = expand('<cword>')
  " set global snippet file
  let l:snippet_file = globpath(g:aergia_snippets, '**/' . l:key)
  " overwrite with filetype specific snippet file if it exists
  if globpath(g:aergia_snippets, '**/' . &filetype . '[_-]' . l:key) !=# ''
    let l:snippet_file = globpath(g:aergia_snippets, '**/' . &filetype . '[-_]' . l:key)
  endif

  if l:snippet_file !=# '' && l:key !=# ''
    return l:snippet_file
  else
    return "file not found"
  endif
endfunction
    " }}}
    " ReplSnippet: replace the word under the cursor with the snippet {{{
function! ReplSnippet()
  let l:snippet_file = FindSnippet()
  if l:snippet_file !=# "file not found" 
    execute "normal! b" . '"_dw'
    let l:cursor = getpos('.')
    let l:indent = IndentSnippet()
    " use sed to prefix the snippet with the correct indentation
    execute "r !cat " . l:snippet_file . "| sed 's/^/" . l:indent . "/g'"
    call setpos('.', l:cursor)
    execute "normal! " . '"_dd'
    call ReplCommandTags(l:snippet_file) " replace all command tags before jumping to the first tag
    call NextTag()
  else
    call NextTag()
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
  " Tags {{{
    " NextTag: select the next tag in the snippet {{{
function! NextTag()
  call ReplNamedTag()
  let l:tag_pattern = s:aergia_start_tag . ".\\+" . s:aergia_end_tag
  try 
    execute "normal! /" . l:tag_pattern . "\<cr>"
    " if current tag is a named tag, store it
    if expand('<cWORD>') =~ '[{][A-Za-z]\+[}]'
      let s:aergia_named_tag = expand('<cword>')
      let s:aergia_named_tag_pos = getpos('.')
    endif
    let l:append = Append()
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
    " Append: append (1) or insert (0) the cursor {{{
function! Append()
  let l:append = 0
  " set append to true if the tag is the last set of chars
  if getline('.') =~ '^[^{+}]*{[^}{]\+}$'
    let l:append = 1
  endif
  return l:append
endfunction
    " }}}
    " ReplNamedTag: replace the current named tag (if any) {{{
function! ReplNamedTag()
  if s:aergia_named_tag !=# ''
    let l:cpos = getpos('.')
    call setpos('.', s:aergia_named_tag_pos)
    execute "%s/{" . s:aergia_named_tag . "}/" . expand('<cword>') . "/g"
    call setpos('.', l:cpos)
    " remove named tag
    let s:aergia_named_tag = ''
  endif
endfunction
    " }}}
    " ReplCommandTags: replace all the command tags (if any) {{{
function! ReplCommandTags(snippet_file)
  let l:tag_pattern = s:aergia_start_tag . "[$][^{}]\\+=\\?[^{}]*" . s:aergia_end_tag
  let l:length = split(system("grep -c '" . l:tag_pattern . "' " . a:snippet_file), '\n')[0]

  let l:i = 0
  while l:i < l:length
    execute "normal! /" . l:tag_pattern . "\<cr>"
    let l:command_tag = matchstr(getline('.'), '{$[^{}]\+}')
    let l:command = matchstr(l:command_tag, '[^${}=]\+')
    try
      execute 'let aergia_command_output = ' . l:command
    catch
      echoerr "AegriaError: couldn't execute command, " . l:command 
    endtry
    let l:append = Append()
    execute "normal! df}"
    if l:append == 0
      execute "normal! i" . aergia_command_output
    else
      execute "normal! a" . aergia_command_output
    endif
    " if the command tag is attached to a named tag, replace the named tags
    let l:name = matchstr(matchstr(l:command_tag, '=[A-Za-z]\+'), '[A-Za-z]\+')
    if l:name !=# ''
      execute "normal! b"
      let s:aergia_named_tag = l:name
      let s:aergia_named_tag_pos = getpos('.')
      call ReplNamedTag()
    endif
    let l:i += 1
  endwhile
endfunction
    " }}}
  " }}}
" }}}
" Mappings {{{
inoremap <silent> <Plug>(aergia) <esc>:call ReplSnippet()<cr>
execute "imap " . g:aergia_key . " <Plug>(aergia)"
" }}}
