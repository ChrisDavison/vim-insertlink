" insert_link.vim - Make and insert links
" Maintainer: Chris Davison <https://chrisdavison.github.io>
" Version: 20200406

" Initialisation {{{1
if exists("g:loaded_insertlink") || &cp || v:version < 700
    finish
endif
let g:loaded_insertlink = 1

let s:cpo_save = &cpo
set cpo&vim

if !exists("g:insertlink_no_keybinds")
  au Filetype markdown,markdown.pandoc nnoremap <buffer> ml :call insertlink#file_from_selection(0)<CR>
  au Filetype markdown,markdown.pandoc vnoremap <buffer> ml :call insertlink#file_from_selection(1)<CR>
  au Filetype markdown,markdown.pandoc nnoremap <buffer> gml :call insertlink#file_from_selection_and_edit(0)<CR>
  au Filetype markdown,markdown.pandoc vnoremap <buffer> gml :call insertlink#file_from_selection_and_edit(1)<CR>
endif

let &cpo = s:cpo_save

" vim:set et sw=2 sts=2:
