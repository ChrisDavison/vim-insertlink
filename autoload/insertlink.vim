function! s:GetVisualSelection(only_on_line) " {{{1
    let l:start_line = line("'<")
    let l:start_col = col("'<")
    let l:end_line = line("'>")
    let l:end_col = col("'>")
    if a:only_on_line && (l:start_line != l:end_line)
        echom "FileFromSelected: Start and end must be same line number"
        return
    end
    return getline(".")[l:start_col-1:l:end_col-1]
endfunction

function! s:GetBeforeAndAfterVisualSelection() " {{{1
    let start_line = line("'<")
    let start_col = col("'<")
    let end_line = line("'>")
    let end_col = col("'>")
    let before=getline(start_line)[:start_col-2]
    if start_col == 1
        let before = ""
    end
    let after=getline(start_line)[end_col:]
    return [before, after]
endfunction

function! s:make_markdown_link(text, url) " {{{1
    return "[" . a:text . "](" . a:url . ")"
endfunction "

function! s:first_line_from_file(filename) abort
    if !filereadable(a:filename)
        echom a:filename . " doesn't exist" 
        throw a:filename . " doesn't exist" 
    endif
    let title=trim(system('head -n1 ' . a:filename))
    return substitute(l:title, "^#\\+ ", "", "")
endfunction

function! s:PathRelativeToCurfile(path, curfile) abort
    let head_of_curfile = fnamemodify(a:curfile, ':h') .. '/'
    " the path leads to a file *inside* a subdirectory of the directory of the current file; we're done
    if stridx(a:path, head_of_curfile) == 0
        return substitute(a:path, head_of_curfile, '../', '')
    endif
    " the path leads to a file *outside*; let's move up in the hierarchy to find it
    return '../' .. s:PathRelativeToCurfile(a:path, fnamemodify(a:curfile, ':h'))
endfunction

function! s:filename_as_relative_to_current(filename) abort "{{{1
    return <sid>PathRelativeToCurfile(a:filename, expand("%:p:h"))
    " let cur=getcwd()
    " let dir_of_curfile=expand("%:p:h")
    " let full=l:cur . "/" . a:filename
    " exec "cd " . l:dir_of_curfile
    " let relative=substitute(fnamemodify(a:filename, ":p"), l:cur, ".", "")
    " exec "cd " . l:cur
    " return l:relative
endfunction

function! s:link_to_file(filename) abort "{{{1
    let rel_filename=<SID>filename_as_relative_to_current(a:filename)
    let title=<sid>first_line_from_file(a:filename)
    return "[" . l:title . "](" . l:rel_filename . ")"
endfunction


" ------------------------------------------------
" THE MAIN FUNCTIONS THAT ARE CALLED FROM COMMANDS
" ------------------------------------------------
function! insertlink#file_from_selection(is_visual) " {{{1
    " Turn the WORD UNDER CURSOR into a link
    let text=a:is_visual ? <sid>GetVisualSelection(1) : expand('<cword>')
    let l:start_line = line(".")
    let l:start_col = col(".")
    let nospace = substitute(l:text, " ", "-", "g")
    let lower = tolower(nospace)
    let sanitised = substitute(lower, "[^a-zA-Z0-9\-]", "", "g")
    let filename="./" . sanitised . ".md"
    let replacetext=s:make_markdown_link(l:text, filename)
    if a:is_visual
        let around_visual = <sid>GetBeforeAndAfterVisualSelection()
        let l:line=around_visual[0] . replacetext . around_visual[1]
        call setline(l:start_line, l:line)
    else
        execute "normal ciw" . l:replacetext
    end
    call cursor(l:start_line, l:start_col+1)
    return filename
endfunction "

function! insertlink#file_from_selection_and_edit(is_visual) " {{{1
    " Turn the WORDS IN VISUAL SELECTION into a link
    exec "w|edit " . insertlink#file_from_selection(a:is_visual)
endfunction " 

function! s:inserttext_at_point(text) abort
    let cur_line_num = line('.')
    let cur_col_num = col('.')
    let orig_line = getline('.')
    let modified_line =
        \ strpart(orig_line, 0, cur_col_num - 1)
        \ . a:text
        \ . strpart(orig_line, cur_col_num - 1)
    " Replace the current line with the modified line.
    call setline(cur_line_num, modified_line)
    " Place cursor on the last character of the inserted text.
    call setpos('.', [0, cur_line_num, cur_col_num + strlen(a:text) - 1, 0])
endfunction


function! insertlink#FirstLineFromFileAsLink(filename) "{{{1
    let rel=<sid>link_to_file(a:filename)
    let lfo=&formatoptions
    set fo-=a
    call <sid>inserttext_at_point(" " . <sid>link_to_file(a:filename))
    let &fo=lfo
endfunction


if exists(':FZF')
    function! insertlink#FirstLineFromFileAsLinkFZF() abort "{{{1
        call fzf#run(fzf#wrap({
                    \ 'source': 'find . -iregex ".*\.md$"', 
                    \ 'sink': function('insertlink#FirstLineFromFileAsLink')
                    \}))
    endfunction
endif


function! insertlink#FirstLineFromFileAsListLinkBelow(filename) "{{{1
    let lfo=&formatoptions
    set fo-=a
    call append(line("."), "- " . <sid>link_to_file(a:filename))
    let &fo=lfo
endfunction
