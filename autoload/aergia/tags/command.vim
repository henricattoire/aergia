" tags/command (v.1.3): process command tags.
" author: Henri Cattoire.

let s:tag = aergia#tags#GetTagInformation()
let s:sep = {
      \ "reuse": ":",
      \ "named": "="
      \ }
" Process {{{
"
" Execute (normal and named) command tags.
function! aergia#tags#command#Process() abort
  while search(s:tag["open"] . '`.\{-1,}`\(' . s:sep["named"] . '[A-Za-z]\+\)\?' . s:tag["close"], 'c')
    let [l:line, l:col] = [getline('.'), col('.') - 1]
    let l:cmd  = matchstr(l:line[l:col:], '`\zs.\{-1,}\ze`\(' . s:sep["named"] . '\|' . s:tag["close"] . '\)')
    let l:out  = eval(l:cmd)
    let l:name = matchstr(l:line[l:col:], s:sep["named"] . '\zs[A-Za-z]\+\ze' . s:tag["close"])
    call aergia#tags#ProcessTag("normal! a" . l:out, "normal! i" . l:out)
    if !empty(l:name)
      " when replacing \n is null byte and \r is actually newline (see :s%)
      silent! execute "%s/" . s:tag["open"] . l:name . s:tag["close"] .  "/" . substitute(l:out, '\n', '\r', 'g') . "/g"
    endif
  endwhile
endfunction
" }}}
" ProcessSpecial {{{
"
" Execute special command tags with the given name, if any.
function! aergia#tags#command#ProcessSpecial(name, input)
  while search(s:tag["open"] . '`.\{-1,}`' . s:sep["reuse"] . a:name . s:tag["close"], 'c')
    let [l:line, l:col] = [getline('.'), col('.') - 1]
    " replace every (not escaped) % with input from the named tag
    let l:cmd  = matchstr(l:line[l:col:], '`\zs.\{-1,}\ze`' . s:sep["reuse"])
    let l:cmd  = substitute(l:cmd, '\(^\|[^\\]\)\zs@', a:input, 'g')
    let l:cmd  = substitute(l:cmd, '\(^\|[^\\]\)@', '@', 'g')
    let l:out  = eval(l:cmd)
    call aergia#tags#ProcessTag("normal! a" . l:out, "normal! i" . l:out)
  endwhile
endfunction
" }}}
