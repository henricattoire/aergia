" tags/named (v.1.3): process named tags.
" author: Henri Cattoire.

let s:stored = {}
let s:tag = aergia#tags#GetTagInformation()
" Process {{{
"
" Process the current named tag.
function! aergia#tags#named#Process()
  if !empty(s:stored)
    let l:pos = getpos('.')
    if l:pos[1] == s:stored.position[1] && l:pos[2] >= s:stored.position[2]
      let l:input = getline(l:pos[1])[s:stored.position[2] - 1:l:pos[2] - 1]
      if l:input !~ '^\s*$'
        silent! execute "%s/" . s:stored.tag .  "/" . l:input . "/g"
        call aergia#tags#command#ProcessSpecial(s:stored["name"], l:input)
      endif
    endif
    unlet s:stored.name
    unlet s:stored.tag
    unlet s:stored.position
    call setpos('.', l:pos)
  endif
endfunction
" }}}
" Store {{{
"
" Store a named tag to be processed later.
function! aergia#tags#named#Store(name)
  let s:stored.name     = a:name
  let s:stored.tag      = s:tag["open"] . a:name . s:tag["close"]
  let s:stored.position = getpos('.')
endfunction
" }}}
