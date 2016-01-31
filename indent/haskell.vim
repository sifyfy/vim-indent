if exists('b:did_indent')
    finish
endif

setlocal autoindent
setlocal indentexpr=GetHaskellIndent()
setlocal indentkeys=!^F,o,O,0<Bar>,0=where,0=else,0=::,0==>

setlocal expandtab
setlocal tabstop<
setlocal softtabstop=4
setlocal shiftwidth=4

let b:undo_indent = 'setlocal '.join([
\   'autoindent<',
\   'expandtab<',
\   'indentexpr<',
\   'indentkeys<',
\   'shiftwidth<',
\   'softtabstop<',
\   'tabstop<',
\ ])


function! GetHaskellIndent()
    if (col('.') - 1) == matchend(getline('.'), '^\s*')
        let plnum = prevnonblank(v:lnum)
        let pl = getline(plnum)

        if pl =~# '\v^\s*where\s*$'
            return indent(plnum) + 2
        endif

        if pl =~# '\s\(do\|->\)\s*$'
            return indent(plnum) + &l:shiftwidth
        endif

        if pl =~# '\sif\s'
            return indent(plnum) + &l:shiftwidth
        endif

        if pl =~# '\scase\s.*\sof\s*$'
            return indent(plnum) + &l:shiftwidth
        endif

        if pl =~# '^\(newtype\s\|data\s\|instance\s\+.*\s\+where\)'
            return indent(plnum) + &l:shiftwidth
        endif
    else
        let plnum = prevnonblank(v:lnum - 1)
        let pl = getline(plnum)
        let current_line = getline(v:lnum)

        if current_line =~# '^\s*where\s*'
            if pl =~# '^\s\+|.*\S\s*=\s*'
                return indent(plnum) - 2
            elseif pl =~# '^.*\S\s*=\s*'
                return indent(plnum) + 2
            else
                return indent(plnum) - 2
            endif
        endif

        if current_line =~# '^\s*else\s*'
            if pl =~# '^\s*then\($\|\s\+\)'
                return -1
            else
                return indent(plnum) - &l:shiftwidth
            endif
        endif

        if current_line =~# '^\s*::\s*'
            return indent(plnum) + &l:shiftwidth
        endif

        if current_line =~# '^\s*=>\s*'
            let n = match(getline(plnum), ' :: ')
            if n >= 0
                return n + 1
            else
                return -1
            endif
        endif
    endif

    return -1
endfunction


let b:did_indent = 1
