" tags (v.0.1): tag related functions.
" author: Henri Cattoire.

" Variables {{{
" tag start and end
let s:aergia_start_tag = '<{'
let s:aergia_end_tag = '}>'
" last named tag properties
let s:aergia_named_tag = ''
let s:aergia_named_tag_pos = [0, 0, 0]
" }}}
" TagFunctions {{{
  " NextTag: select the next tag in the snippet {{{
function! tags#NextTag()
  call tags#ReplNamedTag()
  let l:tag_pattern = s:aergia_start_tag . ".\\+" . s:aergia_end_tag
  try 
    execute "normal! /" . l:tag_pattern . "\<cr>"
    " always go the the first tag in the file
    execute "normal! Gn"
    " if current tag is a named tag, store it
    if expand('<cWORD>') =~ '[<][{][A-Za-z]\+[}][>]'
      let s:aergia_named_tag = expand('<cword>')
      let s:aergia_named_tag_pos = getpos('.')
    endif
    let l:append = tags#Append()
    execute "normal! df" . split(s:aergia_end_tag, '\zs')[-1]
    " append in imode on `empty` lines (do not move cursor one column back)
    if l:append == 0
      execute "startinsert"
    else
      execute "startinsert!"
    endif
  catch /E486.*/
    echom "AegriaWarning: found no tag/snippet"
  endtry
endfunction
  " }}}
  " Append: append (1) or insert (0) the cursor {{{
function! tags#Append()
  let l:append = 0
  " set append to true if the tag is the last set of chars
  if getline('.') =~ '^[^<{+}>]*[<][{][^<}{>]\+[}][>]$'
    let l:append = 1
  endif
  return l:append
endfunction
  " }}}
  " ReplNamedTag: replace the current named tag (if any) {{{
function! tags#ReplNamedTag()
  if s:aergia_named_tag !=# ''
    let l:cpos = getpos('.')
    call setpos('.', s:aergia_named_tag_pos)
    execute "%s/<{" . s:aergia_named_tag . "}>/" . expand('<cword>') . "/g"
    call setpos('.', l:cpos)
    " remove named tag
    let s:aergia_named_tag = ''
  endif
endfunction
  " }}}
  " ReplCommandTags: replace all the command tags (if any) {{{
function! tags#ReplCommandTags(snippet_file)
  let l:tag_pattern = s:aergia_start_tag . "[$][^<{}>]\\+=\\?[^<{}>]*" . s:aergia_end_tag
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
    let l:append = tags#Append()
    execute "normal! df" . split(s:aergia_end_tag, '\zs')[-1]
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
      call tags#ReplNamedTag()
    endif
    let l:i += 1
  endwhile
endfunction
  " }}}
" }}}
