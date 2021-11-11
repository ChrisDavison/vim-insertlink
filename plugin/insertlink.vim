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

command! LinkToFileFromCWord call insertlink#file_from_selection(0)
command! LinkToFileFromVisual  call insertlink#file_from_selection(1)
command! EditFileFromCWord call insertlink#file_from_selection_and_edit(0)
command! EditFileFromVisual call insertlink#file_from_selection_and_edit(1)

command! -complete=file -nargs=1 InsertLinkToNote call insertlink#FirstLineFromFileAsLink(<q-args>)
command! -complete=file -nargs=1 InsertLinkToNoteBelow call insertlink#FirstLineFromFileAsListLinkBelow(<q-args>)

" if !exists("g:insertlink_no_keybinds")
"   au Filetype markdown,markdown.pandoc nnoremap <buffer> <Plug>InsertLinkToFileFromSelection :call insertlink#file_from_selection(0)<CR>
"   au Filetype markdown,markdown.pandoc vnoremap <buffer> ml :call insertlink#file_from_selection(1)<CR>
"   au Filetype markdown,markdown.pandoc nnoremap <buffer> gml :call insertlink#file_from_selection_and_edit(0)<CR>
"   au Filetype markdown,markdown.pandoc vnoremap <buffer> gml :call insertlink#file_from_selection_and_edit(1)<CR>
"   au Filetype markdown,markdown.pandoc nnoremap <leader>il :InsertLinkToNote 
" endif

let &cpo = s:cpo_save

" vim:set et sw=2 sts=2:
