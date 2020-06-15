" tags (v.1.1): tag related functions.
" author: Henri Cattoire.

" Tag Variables {{{
let s:opening = '<{'
let s:typical = '+'
let s:closing = '}>'
let s:pattern = s:opening . '.\{-1,}' . s:closing
" named tag
let s:properties = { "name": '', "position": 0, }
" cmd tag
let s:cmds = s:opening . '`.\{-1,}`\(=[A-Za-z]\+' . s:closing . '\|' . s:closing . '\)'
let s:separator = '='
" }}}
" Tag Functions {{{
  " CanJump {{{
function! aergia#tags#CanJump()
  return search(s:pattern, 'cn')
endfunction
  " }}}
  " JumpTag {{{
function! aergia#tags#JumpTag()
  " if properties contains a named tag, process it
  call s:ProcessNamedTag()

  if search(s:pattern, 'c')
    " if the tag is a named tag, store it
    let l:content = matchstr(getline('.')[col('.') - 1:], s:opening . '\zs.\{-1,}\ze' . s:closing)
    if l:content !=? s:typical
      let s:properties["name"] = l:content
      let s:properties["position"] = getpos('.')
      " remove tag bounds and tell vim the select the name
      call s:ReplTag("normal! a" . s:properties["name"], "normal! i" . s:properties["name"])
      execute "normal! " . s:properties["position"][2] . "|v" . col('.') . "|\<c-g>"
    else
      call s:ReplTag("startinsert!", "startinsert")
    endif
  endif
endfunction
  " }}}
  " ReplTag {{{
function! s:ReplTag(append, insert)
  let [l:oldline, l:colnr] = [getline('.'), col('.')]
  let l:newline = (l:colnr != 1 ? l:oldline[0:l:colnr - 2] : '')
        \ . substitute(l:oldline[l:colnr - 1:], s:pattern, '', '')
  call setline(line('.'), l:newline)
  " append if this tag is the last set of chars on the line
  if l:newline[l:colnr - 1:] =~ '^\s*$'
    execute a:append
  else
    execute a:insert
  endif
endfunction
  " }}}
  " ProcessNamedTag {{{
function! s:ProcessNamedTag()
  if s:properties["name"] !=? ''
    let l:pos = getpos('.')
    silent! execute "%s/" . s:opening . s:properties["name"] . s:closing .  "/"
          \ . getline(s:properties["position"][1])[s:properties["position"][2] - 1:col('.') - 1] . "/g"
    " reset named tag and position
    let s:properties["name"] = ''
    call setpos('.', l:pos)
  endif
endfunction
  " }}}
  " ProcessCmds {{{
function! aergia#tags#ProcessCmds() abort
  while search(s:cmds, 'c')
    let l:cmd = matchstr(getline('.')[col('.') - 1:], '`\zs.\{-1,}\ze`\(=\|' . s:closing . '\)')
    try
      execute 'let output = ' . l:cmd
    catch
      echoerr "AergiaError: couldn't execute command, " . l:cmd
    endtry
    " grab the name this cmd is attached to
    let l:name = matchstr(getline('.')[col('.') - 1:], s:separator . '\zs[A-Za-z]\+\ze' . s:closing)

    call s:ReplTag("normal! a" . output , "normal! i" . output)
    " replace potential named tags
    if l:name !=? ''
      " when replacing \n is null byte and \r is actually newline (see :s%)
      silent! execute "%s/" . s:opening . l:name . s:closing .  "/" . substitute(output, '\n', '\r', 'g') . "/g"
    endif
    unlet output
  endwhile
endfunction
  " }}}
" }}}
