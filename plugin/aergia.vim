" aergia (v.1.1): a straightforward snippet manager.
" author: Henri Cattoire.

if exists('g:aergia_loaded')
  finish
endif
let g:aergia_loaded = 1
let s:save_cpo = &cpo
set cpo&vim
" Global Variables {{{
if !exists('g:aergia_snippets')
  let g:aergia_snippets = expand('~/.vim/snippets')
else
  let g:aergia_snippets = expand(g:aergia_snippets)
endif

if !exists('g:aergia_key')
  let g:aergia_key = '<c-a>'
endif

if get(g:, 'aergia_expand', 0)
  augroup aergia_expand
    autocmd!
    autocmd CompleteDone * call aergia#completion#AergiaExpand(v:completed_item)
  augroup end
endif
" }}}
" Mappings {{{
if !get(g:, 'no_plugin_maps', 0)
  inoremap <silent> <Plug>(aergia) <esc>:call aergia#ReplSnippet()<cr>
  snoremap <silent> <Plug>(aergia) <esc>:call aergia#ReplSnippet()<cr>
  if get(g:, 'aergia_mappings', 1)
    execute "imap " . g:aergia_key . " <Plug>(aergia)"
    execute "smap " . g:aergia_key . " <Plug>(aergia)"
  endif
endif
" }}}
" Commands {{{
command -nargs=1 AergiaAddSnippet :call aergia#commands#AergiaAddSnippet(<f-args>)
command -nargs=1 -complete=customlist,aergia#completion#ListSnippets AergiaEditSnippet   :call aergia#commands#AergiaEditSnippet(<f-args>)
command -nargs=1 -complete=customlist,aergia#completion#ListSnippets AergiaRemoveSnippet :call aergia#commands#AergiaRemoveSnippet(<f-args>)
command -nargs=1 -complete=customlist,aergia#completion#ListSnippets AergiaInsertSnippet :call aergia#commands#AergiaInsertSnippet(<f-args>)
command AergiaJumpTag :call aergia#tags#JumpTag()
" }}}
let &cpo = s:save_cpo
unlet s:save_cpo
