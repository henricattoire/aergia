" tags (v.1.3): tag related functions.
" author: Henri Cattoire.

let s:stored = {}
" tag information
let s:tag = {
      \ "open" : "<|",
      \ "close": "|>",
      \ }
" match regular and named tags (no command tags)
let s:tag.regex = s:tag["open"] . '.\{-1,}' . s:tag["close"]
let s:tag.dbody = "+" " default body
" NextTag {{{
"
" Checks if there is a next tag to jump to.
function! aergia#tags#NextTag() abort
  return search(s:tag["open"] . '[^`]\{-1,}' . s:tag["close"], 'cn')
endfunction
" }}}
" Jump {{{
"
" Jump to the next tag, if any.
function! aergia#tags#Jump() abort
  call aergia#tags#named#Process()
  " never jump to command tags
  if search(s:tag["open"] . '[^`]\{-1,}' . s:tag["close"], 'c')
    let l:body = matchstr(getline('.')[col('.') - 1:], s:tag["open"] . '\zs.\{-1,}\ze' . s:tag["close"])
    if l:body !=? s:tag.dbody
      let l:pos = getpos('.')
      call aergia#tags#named#Store(l:body)
      call aergia#tags#ProcessTag("normal! a" . l:body , "normal! i" . l:body, s:tag.regex)
      execute "normal! " . l:pos[2] . "|v" . col('.') . "|\<c-g>"
    else
      call aergia#tags#ProcessTag("startinsert!", "startinsert", s:tag.regex)
    endif
  endif
endfunction
" }}}
" ProcessTag {{{
"
" Process tag at the current position by removing it and entering
" insert mode (using insert or append).
function! aergia#tags#ProcessTag(append, insert, regex) abort
  let [l:line, l:col] = [getline('.'), col('.')]
  let l:without_tag = (l:col != 1 ? l:line[0:l:col - 2] : '') . substitute(l:line[l:col - 1:], a:regex, '', '')
  call setline(line('.'), l:without_tag)
  " append when cursor is now at the end of the line
  execute (l:without_tag[col('.') - 1:] =~ '^\s*$' ? a:append : a:insert)
endfunction
" }}}
" GetTagInformation {{{
"
" Get information about tag.
function! aergia#tags#GetTagInformation() abort
  return s:tag
endfunction
" }}}
