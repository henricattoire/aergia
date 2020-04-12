" tags (v.0.1): tag related functions.
" author: Henri Cattoire.

" Tag Variables {{{
" tag start and end
let s:start_tag = '<{'
let s:end_tag = '}>'
" last named tag properties
let s:named_tag = ''
let s:named_tag_pos = 0
" }}}
" Tag Functions {{{
  " NextTag: select the next tag in the snippet {{{
function! tags#NextTag()
  call tags#ReplNamedTag()
  let l:tag_pattern = s:start_tag . "[^>]\\+" . s:end_tag
  try 
    execute "normal! /" . l:tag_pattern . "\<cr>"
    " if current tag is a named tag, store it
    let l:inner_tag = matchstr(getline('.'), "[<][{][^>+]\\+[}][>]")
    if l:inner_tag != '' && matchstr(getline('.'), "^.*<{+}>.*" . l:inner_tag) == ''
      let s:named_tag = matchstr(l:inner_tag, "[^<{}>]\\+")
      let s:named_tag_pos = getpos('.')
    endif
    if s:named_tag != ''
      call tags#InsertTag("normal! a" . s:named_tag, "normal! i" . s:named_tag)
      execute "normal! v" . s:named_tag_pos[2] . "|" . "\<c-g>"
    else
      call tags#InsertTag("startinsert!", "startinsert")
    endif
  catch /E486.*/
    echom "AergiaWarning: found no tag/snippet"
  endtry
endfunction
  " }}}
  " InsertTag: edit the tag in append or insert mode {{{
function! tags#InsertTag(a_action, i_action)
  " append is true if the tag is the last set of chars
  if getline('.') =~ '^[^<{+}>]*[<][{][^<}{>]\+[}][>]$'
    execute "normal! df" . split(s:end_tag, '\zs')[-1]
    execute a:a_action
  else
    execute "normal! df" . split(s:end_tag, '\zs')[-1]
    execute a:i_action
  endif
endfunction
  " }}}
  " ReplNamedTag: replace the current named tag (if any) {{{
function! tags#ReplNamedTag()
  if s:named_tag != ''
    let l:cpos = getpos('.')
    call setpos('.', s:named_tag_pos)
    try
      execute "%s/<{" . s:named_tag . "}>/" . expand('<cword>') . "/g"
    catch /E486.*/
    endtry
    call setpos('.', l:cpos)
    " remove named tag
    let s:named_tag = ''
  endif
endfunction
  " }}}
  " ReplCommandTags: replace all the command tags (if any) {{{
function! tags#ReplCommandTags(snippet_file)
  let l:tag_pattern = s:start_tag . "[$][^<{}>]\\+=\\?[^<{}>]*" . s:end_tag
  let l:length = split(system("grep -c '" . l:tag_pattern . "' " . a:snippet_file), '\n')[0]

  let l:i = 0
  while l:i < l:length
    execute "normal! /" . l:tag_pattern . "\<cr>"
    let l:command_tag = matchstr(getline('.'), '{$[^<{}>]\+}')
    let l:command = matchstr(l:command_tag, '[^$<{}>=]\+')
    try
      execute 'let aergia_command_output = ' . l:command
    catch
      echoerr "AegriaError: couldn't execute command, " . l:command 
    endtry
    call tags#InsertTag("normal! a" . aergia_command_output, "normal! i" . aergia_command_output)
    " if the command tag is attached to a named tag, replace the named tags
    let l:name = matchstr(matchstr(l:command_tag, '=[A-Za-z]\+'), '[A-Za-z]\+')
    if l:name != ''
      execute "normal! b"
      let s:named_tag = l:name
      let s:named_tag_pos = getpos('.')
      call tags#ReplNamedTag()
    endif
    let l:i += 1
  endwhile
endfunction
  " }}}
" }}}
