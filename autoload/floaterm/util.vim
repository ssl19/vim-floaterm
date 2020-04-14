" ============================================================================
" FileName: autoload/floaterm/util.vim
" Author: voldikss <dyzplus@gmail.com>
" GitHub: https://github.com/voldikss
" ============================================================================

function! s:echo(group, msg) abort
    if a:msg ==# '' | return | endif
    execute 'echohl' a:group
    echo a:msg
    echon ' '
    echohl NONE
endfunction

function! s:echon(group, msg) abort
    if a:msg ==# '' | return | endif
    execute 'echohl' a:group
    echon a:msg
    echon ' '
    echohl NONE
endfunction

function! floaterm#util#show_msg(message, ...) abort
    if a:0 == 0
        let msg_type = 'info'
    else
        let msg_type = a:1
    endif

    if type(a:message) != 1
        let message = string(a:message)
    else
        let message = a:message
    endif

    call s:echo('Constant', '[vim-floaterm]')

    if msg_type ==# 'info'
        call s:echon('Normal', message)
    elseif msg_type ==# 'warning'
        call s:echon('WarningMsg', message)
    elseif msg_type ==# 'error'
        call s:echon('Error', message)
    endif
endfunction

function! floaterm#util#edit(filename) abort
    call floaterm#util#hide_buffer()
    silent execute g:floaterm_open_command . ' ' . a:filename
endfunction


function floaterm#util#startinsert()
    if g:floaterm_autoinsert == v:true
        if has('nvim')
            startinsert
        else
            silent! execute 'normal! i'
        endif
    endif
endfunction


" Hide current before opening another terminal window
function! floaterm#util#hide_buffer(...) abort
    let argv_1 = a:000
let window_opts = getbufvar(bufnr('%'), 'floaterm_window_opts', {}) 
    if !has('nvim') && get(window_opts, 'wintype', '') == 'floating' 
        call popup_close(win_getid())
    else
        while v:true
            let found_winnr = floaterm#window#find_floaterm_winnr()
            if found_winnr > 0
                execute found_winnr . 'hide'
            else
                break
            endif
        endwhile
    endif
endfunction
