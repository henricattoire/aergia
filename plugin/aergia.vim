" aergia (v.1.3): a small, straightforward snippet manager.
" author: Henri Cattoire.

if exists('g:aergia_loaded') || v:version < 704 || &compatible
  finish
endif
let g:aergia_loaded = 1

let s:save_cpo = &cpo
set cpo&vim
" Global Variables {{{
let g:aergia_snippets = expand(get(g:, 'aergia_snippets', '~/.vim/snippets'))
let g:aergia_cache    = get(g:, 'aergia_cache', 1)
let g:aergia_trigger  = get(g:, 'aergia_trigger', '<c-a>')

if get(g:, 'aergia_expand', 0)
  augroup aergia_expand
    autocmd!
    autocmd CompleteDone * call aergia#complete#ExpandCompletedItem(v:completed_item)
  augroup end
endif
" }}}
" Mappings {{{
inoremap <silent> <Plug>(aergia) <esc>:call aergia#ExpandOrJump()<cr>
snoremap <silent> <Plug>(aergia) <esc>:call aergia#ExpandOrJump()<cr>
execute "imap " . g:aergia_trigger . " <Plug>(aergia)"
execute "smap " . g:aergia_trigger . " <Plug>(aergia)"
" }}}
let &cpo = s:save_cpo
unlet s:save_cpo
