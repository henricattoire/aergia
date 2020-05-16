" tags (v.0.3): tag related functions.
" author: Henri Cattoire.

" Tag Variables {{{
let s:opening = '<{'
let s:typical = '+' " content of a 'typical' (not special) tag
let s:closing = '}>'
let s:pattern = s:opening . '[^>]\+' . s:closing " prevent greedy match
" named tag
let s:properties = { "name": '', "position": 0, }
" cmd tag
let s:cmds = s:opening . '[$][^' . s:opening . s:closing . ']\+=\?'
      \ . '[^' . s:opening . s:closing . ']*' . s:closing
let s:special = '$='
" }}}
" Tag Functions {{{
  " JumpTag {{{
function! aergia#tags#JumpTag()
  " if properties contains a named tag, process it
  call s:ProcessNamedTag()

  if search(s:pattern, 'c')
    " if the tag is a named tag, store it
    let l:content = matchstr(getline('.')[col('.') - 1:], '[^' . s:opening . s:closing . ']\+')
    if l:content !=? s:typical
      let s:properties["name"] = l:content
      let s:properties["position"] = getpos('.')
      " remove tag bounds and tell vim the select the name
      call s:ReplTag("normal! a" . s:properties["name"], "normal! i" . s:properties["name"])
      execute "normal! v" . s:properties["position"][2] . "|\<c-g>"
    else
      call s:ReplTag("startinsert!", "startinsert")
    endif
  endif
endfunction
  " }}}
  " ReplTag {{{
function! s:ReplTag(append, insert)
  " append if this tag is the last set of chars on the line
  if getline('.')[col('.') - 1:] =~ '^' . s:pattern . '$'
    execute "normal! " . '"_df' . s:closing[-1:]
    execute a:append
  else
    execute "normal! " .  '"_df' . s:closing[-1:]
    execute a:insert
  endif
endfunction
  " }}}
  " ProcessNamedTag {{{
function! s:ProcessNamedTag()
  " replace named tag with the cword on postion inside properties
  if s:properties["name"] !=? ''
    let l:current = getpos('.') " current position, so we can jump back later
    silent! execute "%s/" . s:opening . s:properties["name"] . s:closing .  "/"
          \ . getline(s:properties["position"][1])[s:properties["position"][2] - 1:l:current[2] - 1] . "/g"
    " reset named tag
    let s:properties["name"] = ''
  endif
endfunction
  " }}}
  " ProcessCmds {{{
function! aergia#tags#ProcessCmds() abort
  while search(s:cmds, 'c')
    let l:cmd = matchstr(getline('.')[col('.') - 1:], '[^' . s:special . s:opening . s:closing . ']\+')
    try
      execute 'let output = ' . l:cmd
    catch
      echoerr "AegriaError: couldn't execute command, " . l:cmd
    endtry
    " grab the name this cmd is attached to
    let l:name = matchstr(getline('.')[col('.') - 1:], s:special[-1] . '[^' . s:opening . s:closing . ']\+')

    call s:ReplTag("normal! a" . output , "normal! i" . output)
    " replace potential named tags
    if l:name !=? ''
      " for now only cmds that have one word as output are supported
      execute "normal! b"
      let s:properties["name"] = l:name
      let s:properties["position"] = getpos('.')
      call s:ProcessNamedTag()
    endif
  endwhile
endfunction
  " }}}
" }}}
