" tags (v.1.2): tag related functions.
" author: Henri Cattoire.

" Tag Variables {{{
let s:opening = get(g:aergia_tag, 'open',  '<|')
let s:closing = get(g:aergia_tag, 'close', '|>')
let s:pattern = s:opening . '.\{-1,}' . s:closing
  " Default
let s:default = '+'
  " Command
let s:sep = '='
let s:command = s:opening . '`.\{-1,}`\(' . s:sep . '[A-Za-z]\+\)\?' . s:closing
" }}}
" Tag Functions {{{
  " Can Aergia Jump? {{{
function! aergia#tags#CanJump() abort
  return search(s:pattern, 'cn')
endfunction
  " }}}
  " Jump {{{
function! aergia#tags#Jump() abort
  " if properties contains a named tag, process it
  call s:ProcessName()

  if search(s:pattern, 'c')
    " if the tag is a named tag, store it
    let l:content = matchstr(getline('.')[col('.') - 1:], s:opening . '\zs.\{-1,}\ze' . s:closing)
    if l:content !=? s:default
      let s:properties = { "name": l:content, "position": getpos('.'), }
      " replace tag and select name
      call s:Replace("normal! a" . s:properties["name"], "normal! i" . s:properties["name"])
      execute "normal! " . s:properties["position"][2] . "|v" . col('.') . "|\<c-g>"
    else
      call s:Replace("startinsert!", "startinsert")
    endif
  endif
endfunction
  " }}}
  " Replace {{{
function! s:Replace(append, insert) abort
  " append if this tag is the last set of chars on the line
  execute (s:Remove()[col('.') - 1:] =~ '^\s*$' ? a:append : a:insert)
endfunction
  " }}}
  " Remove {{{
function! s:Remove() abort
  let [l:line, l:col] = [getline('.'), col('.')]
  let l:tagless = (l:col != 1 ? l:line[0:l:col - 2] : '') . substitute(l:line[l:col - 1:], s:pattern, '', '')
  call setline(line('.'), l:tagless)
  return l:tagless
endfunction
  " }}}
  " ProcessName {{{
function! s:ProcessName() abort
  if exists('s:properties')
    let l:cpos = getpos('.')
    if l:cpos[1] == s:properties["position"][1] && l:cpos[2] >= s:properties["position"][2]
      let l:varName = getline(s:properties["position"][1])[s:properties["position"][2] - 1:l:cpos[2] - 1]
      if l:varName !~ '^\s*$'
        silent! execute "%s/" . s:opening . s:properties["name"] . s:closing .  "/" . l:varName . "/g"
      endif
    endif
    unlet s:properties
    call setpos('.', l:cpos)
  endif
endfunction
  " }}}
  " ProcessCommands {{{
function! aergia#tags#ProcessCommands() abort
  while search(s:command, 'c')
    let [l:line, l:col] = [getline('.'), col('.') - 1]
    " grab and execute command
    let l:cmd = matchstr(l:line[l:col:], '`\zs.\{-1,}\ze`\(' . s:sep . '\|' . s:closing . '\)')
    let l:out = eval(cmd)
    " grab id (read: name) this cmd is attached to
    let l:id = matchstr(l:line[l:col:], s:sep . '\zs[A-Za-z]\+\ze' . s:closing)

    call s:Replace("normal! a" . out, "normal! i" . out)
    " replace potential named tags
    if !empty(l:id)
      " when replacing \n is null byte and \r is actually newline (see :s%)
      silent! execute "%s/" . s:opening . l:id . s:closing .  "/" . substitute(out, '\n', '\r', 'g') . "/g"
    endif
  endwhile
endfunction
  " }}}
" }}}
