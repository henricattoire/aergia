" aergia (v.1.2): a small, straightforward snippet manager.
" author: Henri Cattoire.

if exists('g:aergia_loaded') || v:version < 701 || &compatible
  finish
endif
let g:aergia_loaded = 1

let s:save_cpo = &cpo
set cpo&vim
" Global Variables {{{
let g:aergia_snippets = expand(get(g:, 'aergia_snippets', '~/.vim/snippets'))
let g:aergia_trigger  = get(g:, 'aergia_trigger', '<c-a>')
let g:aergia_tag = get(g:, 'aergia_tag', { 'open': '<|', 'close': '|>' })

if get(g:, 'aergia_expand', 0)
  augroup aergia_expand
    autocmd!
    autocmd CompleteDone * call aergia#completion#AergiaExpand(v:completed_item)
  augroup end
endif
" }}}
" Mappings {{{
inoremap <silent> <Plug>(aergia) <esc>:call aergia#Respond()<cr>
snoremap <silent> <Plug>(aergia) <esc>:call aergia#Respond()<cr>
execute "imap " . g:aergia_trigger . " <Plug>(aergia)"
execute "smap " . g:aergia_trigger . " <Plug>(aergia)"
" }}}
" Commands {{{
command -nargs=1 AergiaAddSnippet :call aergia#commands#AergiaAddSnippet(<f-args>)
command -nargs=1 -complete=customlist,aergia#completion#ListSnippets AergiaEditSnippet :call aergia#commands#AergiaEditSnippet(<f-args>)
command -nargs=1 -complete=customlist,aergia#completion#ListSnippets AergiaRemoveSnippet :call aergia#commands#AergiaRemoveSnippet(<f-args>)
command -nargs=+ -complete=customlist,aergia#completion#ListSnippets AergiaShareSnippet :call aergia#commands#AergiaShareSnippet(<f-args>)
" }}}
let &cpo = s:save_cpo
unlet s:save_cpo
