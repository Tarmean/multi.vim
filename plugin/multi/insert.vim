function! multi#insert#setup(input, type)
    let s:changes = 0
    call g:multi#state_manager.apply(g:multi#command#insert, 'prime_normal', a:input, 1)
    while 1
        let s:first = s:changes
        let s:changes = 1
        let c = getchar()
        if type(c) == 0
            let s = nr2char(c)
        else
            let s = c
        endif
        if s == "\<Esc>"
            break
        endif
        unlet c
        call g:multi#state_manager.apply(g:multi#command#insert, 'normal', s, 1)
    endwhile
endfunction

let multi#command#insert = {}
function multi#command#insert.prime_normal(area, command)
    call setpos(".", a:area.cursor)
    let tick = b:changedtick
    if !s:changes
        execute "silent norm ".a:command
        if tick != b:changedtick
            let s:changes = 1
        endif
    else
        undojoin|execute "silent norm ".a:command
    endif
    let new_area = multi#util#new_area("normal")
    let new_area[2] = getpos("'^")[2] - 1
    if new_area[2] == 0
        let new_area[2] = 1
        let new_area.col_0 = 1
    else
        let new_area.col_0 = 0
    endif
    " echo b:changedtick
    " call getchar()
    return [new_area]
endfunction
function multi#command#insert.normal(area, command)
    call setpos(".", a:area.cursor)
    let insert_direction =  a:area.col_0 == 0 ? 'a' : 'i'
    " echo b:changedtick
    " call getchar()
    if s:first
        undojoin | execute "norm! ".insert_direction.a:command
        let s:first = 0
    else
        execute "norm ".insert_direction.a:command
    endif
    let new_area = multi#util#new_area("normal")
    let new_area[2] = getpos("'^")[2] - 1
    if new_area[2] == 0
        let new_area[2] = 1
        let new_area.col_0 = 1
    else
        let new_area.col_0 = 0
    endif
    return [new_area]
endfunction


" function multi#command#insert.normal(area, command)
"     call multi#util#setup(a:area.cursor)
"     if self.undo_count > 1
"         undojoin | silent norm .
"     else
"         silent norm .
"     endif
"     if g:multi#state_manager.state.tick != b:changedtick
"         let self.undo_count += 1
"     endif
"     return [multi#util#new_area('normal')]
" endfunction
" function! Update_insert()
"     redraw
" endfunction
