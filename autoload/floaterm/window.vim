" ============================================================================
" FileName: floatwin.vim
" Author: voldikss <dyzplus@gmail.com>
" GitHub: https://github.com/voldikss
" ============================================================================

" winid: floaterm window id
if has('nvim')
function! s:add_border(winid) abort
    let win_opts = nvim_win_get_config(a:winid)
    let top = g:floaterm_borderchars[4] .
                \ repeat(g:floaterm_borderchars[0], win_opts.width) .
                \ g:floaterm_borderchars[5]
    let mid = g:floaterm_borderchars[3] .
                \ repeat(' ', win_opts.width) .
                \ g:floaterm_borderchars[1]
    let bot = g:floaterm_borderchars[7] .
                \ repeat(g:floaterm_borderchars[2], win_opts.width) .
                \ g:floaterm_borderchars[6]
    let lines = [top] + repeat([mid], win_opts.height) + [bot]
    let buf_opts = {}
    let buf_opts.synmaxcol = 3000 " #17
    let buf_opts.filetype = 'floaterm_border'
    " Reuse s:add_border
    let border_bufnr = floaterm#buffer#create(lines, buf_opts)
    call nvim_buf_set_option(border_bufnr, 'bufhidden', 'wipe')
    let win_opts.row -= (win_opts.anchor[0] == 'N' ? 1 : -1)
    " A bug fix
    if win_opts.row < 0
        let win_opts.row = 1
        call nvim_win_set_config(a:winid, win_opts)
        let win_opts.row = 0
    endif
    let win_opts.col -= (win_opts.anchor[1] == 'W' ? 1 : -1)
    let win_opts.width += 2
    let win_opts.height += 2
    let win_opts.style = 'minimal'
    let win_opts.focusable = v:false
    let border_winid = nvim_open_win(border_bufnr, v:false, win_opts)
    call nvim_win_set_option(border_winid, 'winhl', 'NormalFloat:FloatermBorderNF')
    return border_winid
endfunction
endif
function! s:floatwin_pos(width, height, pos) abort
    if has('nvim')
        if a:pos == 'topright'
            let row = 2
            let col = &columns - 1
            let anchor = 'NE'
        elseif a:pos == 'topleft'
            let row = 2
            let col = 1
            let anchor = 'NW'
        elseif a:pos == 'bottomright'
            let row = &lines - 3
            let col = &columns - 1
            let anchor = 'SE'
        elseif a:pos == 'bottomleft'
            let row = &lines - 3
            let col = 1
            let anchor = 'SW'
        elseif a:pos == 'top'
            let row = 2
            let col = (&columns - a:width)/2
            let anchor = 'NW'
        elseif a:pos == 'right'
            let row = (&lines - a:height)/2
            let col = &columns - 1
            let anchor = 'NE'
        elseif a:pos == 'bottom'
            let row = &lines - 3
            let col = (&columns - a:width)/2
            let anchor = 'SW'
        elseif a:pos == 'left'
            let row = (&lines - a:height)/2
            let col = 1
            let anchor = 'NW'
        elseif a:pos == 'center'
            let row = (&lines - a:height)/2
            let col = (&columns - a:width)/2
            let anchor = 'NW'
            if row < 0
                let row = 0
            endif
            if col < 0
                let col = 0
            endif
        else " at the cursor place
            let curr_pos = getpos('.')
            let row = curr_pos[1] - line('w0')
            let col = curr_pos[2]
            if row + a:height <= &lines
                let vert = 'N'
            else
                let vert = 'S'
            endif
            if col + a:width <= &columns
                let hor = 'W'
            else
                let hor = 'E'
            endif
            let anchor = vert . hor
        endif
    else 
        if a:pos == 'topright'
            let row = 2
            let col = &columns - 1
            let anchor = 'topright'
        elseif a:pos == 'topleft'
            let row = 2
            let col = 1
            let anchor = 'topleft'
        elseif a:pos == 'bottomright'
            let row = &lines - 3
            let col = &columns - 1
            let anchor = 'botright'
        elseif a:pos == 'bottomleft'
            let row = &lines - 3
            let col = 1
            let anchor = 'botleft'
        elseif a:pos == 'top'
            let row = 2
            let col = float2nr((&columns - a:width)/2)
            let anchor = 'topleft'
        elseif a:pos == 'right'
            let row = float2nr((&lines - a:height)/2)
            let col = &columns - 1
            let anchor = 'topright'
        elseif a:pos == 'bottom'
            let row = &lines - 3
            let col = float2nr((&columns - a:width)/2)
            let anchor = 'botleft'
        elseif a:pos == 'left'
            let row = float2nr((&lines - a:height)/2)
            let col = 1
            let anchor = 'topright'
        elseif a:pos == 'center'
            let row = float2nr((&lines - a:height)/2)
            let col = float2nr((&columns - a:width)/2)
            let anchor = 'center'
            if row < 0
                let row = 0
            endif
            if col < 0
                let col = 0
            endif
        else " at the cursor place
            let row = 'cursor'
            let col = 'cursor'
            let anchor = 'topleft'
        endif
    endif
    return [row, col, anchor]
endfunction
function! floaterm#window#nvim_open_win(bufnr, width, height, pos) abort
    if has('nvim')
        let [row, col, anchor] = s:floatwin_pos(a:width, a:height, a:pos)
        let opts = {
                    \ 'relative': 'editor',
                    \ 'anchor': anchor,
                    \ 'row': row,
                    \ 'col': col,
                    \ 'width': a:width,
                    \ 'height': a:height,
                    \ 'style':'minimal'
                    \ }
        let winid = nvim_open_win(a:bufnr, v:true, opts)
        let border_winid = getbufvar(a:bufnr, 'floaterm_border_winid', v:null)
        if border_winid == v:null || !s:winexists(border_winid)
            let border_winid = s:add_border(winid)
            call setbufvar(a:bufnr, 'floaterm_border_winid', border_winid)
        endif
        call nvim_set_current_win(winid)
    else 
        let [row, col, anchor] = s:floatwin_pos(a:width, a:height, a:pos)
        let width =  a:width
        let height =  a:height
        let opts = {
                    \ 'pos': anchor,
                    \ 'line': row,
                    \ 'col': col,
                    \ 'maxwidth': width,
                    \ 'minwidth': width,
                    \ 'maxheight': height,
                    \ 'minheight': height,
                    \ 'border': [],
                    \ 'borderchars': ['─', '│', '─', '│', '┌', '┐', '┘', '└'],
                    \ 'borderhighlight': [ 'Todo' ],
                    \ 'padding': [0,1,0,1],
                    \ 'highlight': 'Terminal'
                    \ }
        let winid = popup_create(a:bufnr, opts)
        call setbufvar(winbufnr(winid), '&filetype', 'floaterm')
    endif
    return winid 
endfunction
function! s:winexists(winid) abort
    return !empty(getwininfo(a:winid))
endfunction

function! floaterm#window#hide_border(bufnr, ...) abort
    let winid = getbufvar(a:bufnr, 'floaterm_border_winid', v:null)
    if winid != v:null && s:winexists(winid)
        call nvim_win_close(winid, v:true)
    endif
    call setbufvar(a:bufnr, 'floaterm_border_winid', v:null)
endfunction

" Find **one** floaterm window
function! floaterm#window#find_floaterm_winnr() abort
    let found_winnr = 0
    for winnr in range(1, winnr('$'))
        if getbufvar(winbufnr(winnr), '&filetype') ==# 'floaterm'
            let found_winnr = winnr
            break
        endif
    endfor
    return found_winnr
endfunction

function! floaterm#window#open_split(height, width, pos) abort
    if a:pos == 'top'
        execute 'topleft' . a:height . 'split'
    elseif a:pos == 'left'
        execute 'topleft' . a:width . 'vsplit'
    elseif a:pos == 'right'
        execute 'botright' . a:width . 'vsplit'
    else " default position: bottom
        execute 'botright' . a:height . 'split'
    endif
endfunction
