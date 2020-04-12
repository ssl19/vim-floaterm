" ============================================================================
" FileName: debug.vim
" Author: voldikss <dyzplus@gmail.com>
" GitHub: https://github.com/voldikss
" ============================================================================

let s:log = []

function! floaterm#debug#init() abort
  let s:log = []
endfunction

function! floaterm#debug#info(...) abort
  if !g:floaterm_debug | return | endif
  let trace = expand('<sfile>')[:-22]
  let log = {}
  let info = get(a:, 1, '')
  let log[trace] = info
  call add(s:log, log)
endfunction

function! floaterm#debug#open_log() abort
  if !g:floaterm_debug
    call floaterm#util#show_msg('You must Set g:floaterm_debug to v:true', 'warning')
    return
  endif
  bo vsplit vim-floaterm.log
  setlocal buftype=nofile
  setlocal commentstring=@\ %s
  call matchadd('Constant', '\v\@.*$')
  for log in s:log
    for [k,v] in items(log)
      call append('$', '@' . k)
      if type(v) == v:t_dict || type(v) == v:t_list
        call append('$', string(v))
      else
        call append('$', v)
      endif
      call append('$', '')
    endfor
  endfor
endfunction
