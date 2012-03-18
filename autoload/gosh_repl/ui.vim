"=============================================================================
" FILE: ui.vim
" AUTHOR:  aharisu <foo.yobina@gmail.com>
" Last Modified: 18 Mar 2012.
" License: MIT license  {{{
"     Permission is hereby granted, free of charge, to any person obtaining
"     a copy of this software and associated documentation files (the
"     "Software"), to deal in the Software without restriction, including
"     without limitation the rights to use, copy, modify, merge, publish,
"     distribute, sublicense, and/or sell copies of the Software, and to
"     permit persons to whom the Software is furnished to do so, subject to
"     the following conditions:
"
"     The above copyright notice and this permission notice shall be included
"     in all copies or substantial portions of the Software.
"
"     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
"     OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
"     MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
"     IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
"     CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
"     TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
"     SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
" }}}
"=============================================================================

let s:gosh_context = {}
let s:default_open_cmd = '15:split'

function! gosh_repl#ui#open_new_repl()"{{{
  let bufnr = s:move_to_window('gosh-repl')

  if bufnr == 0
    silent! execute s:default_open_cmd
    enew
    let bufnr = bufnr('%')

    let context = gosh_repl#create_gosh_context(s:funcref('exit_callback'))
    let context.context__key = bufnr
    let s:gosh_context[bufnr] = context

    call s:initialize_buffer()
    call gosh_repl#check_output(context, 50)
  else
    call cursor(line('$'), col('$'))
  endif

  startinsert!
endfunction"}}}

function! s:exit_callback(context)"{{{
  execute a:context.context__key 'wincmd q'
  if has_key(s:gosh_context, a:context.context__key)
    unlet s:gosh_context[a:context.context__key]
  endif
endfunction"}}}

function! s:initialize_buffer()"{{{
  setlocal buftype=nofile noswapfile
  setlocal bufhidden=delete
  setlocal nonumber

  setlocal filetype=gosh-repl
  setlocal syntax=gosh-repl

  autocmd BufUnload <buffer> call s:unload_buffer()
  autocmd CursorHold <buffer> call s:check_output(500)
  autocmd CursorHoldI <buffer> call s:check_output(500)
  autocmd CursorMoved <buffer> call s:check_output(0)
  autocmd CursorMovedI <buffer> call s:check_output(0)

  call gosh_repl#mapping#initialize()

endfunction"}}}

function! gosh_repl#ui#get_context(bufnr)"{{{
  return s:gosh_context[a:bufnr]
endfunction"}}}

function! s:unload_buffer()"{{{
  if has_key(s:gosh_context, bufnr('%'))
    call gosh_repl#destry_gosh_context(s:gosh_context[bufnr('%')])
    unlet s:gosh_context[bufnr('%')]
  endif

  autocmd! * <buffer>
endfunction"}}}

function! s:check_output(timeout)"{{{
  if has_key(s:gosh_context, bufnr('%'))
    call gosh_repl#check_output(s:gosh_context[bufnr('%')], a:timeout)
  endif
endfunction"}}}

function! gosh_repl#ui#clear_buffer()"{{{
  if &filetype == 'gosh-repl'
    % delete _

    let bufnr = bufnr('%')
    if has_key(s:gosh_context, bufnr)
      call gosh_repl#destry_gosh_context(s:gosh_context[bufnr])

      let context = gosh_repl#create_gosh_context(s:funcref('exit_callback'))
      let context.context__key = bufnr
      let s:gosh_context[bufnr] = context

      call gosh_repl#check_output(context, 50)
    endif
  else
    echohl WarningMsg | echomsg 'use only in the GoshREPL buffer' | echohl None
  endif
endfunction"}}}

"
"window operation

function! s:move_to_window(filetype)"{{{
  for i in range(0, winnr('$'))
    let n = winbufnr(i)
    if getbufvar(n, '&filetype') ==# a:filetype
      if i != 0
        execute i 'wincmd w'
      endif
      return n
    endif
  endfor

  return 0
endfunction"}}}

function! s:mark_back_to_window()"{{{
  let w:ref_back = 1
endfunction"}}}

function! s:unmark_back_to_window()"{{{
  unlet! w:ref_back
endfunction"}}}

function! s:back_to_marked_window()"{{{
  for t in range(1, tabpagenr('$'))
    for w in range(1, winnr('$'))
      if gettabwinvar(t, w, 'ref_back')
        execute 'tabnext' t
        execute w 'wincmd w'
        unlet! w:ref_back
      endif
    endfor
  endfor
endfunction"}}}


"
"Util

"from vimproc plugin s:funcref(funcname)"{{{
function! s:SID_PREFIX()
  return matchstr(expand('<sfile>'), '<SNR>\d\+_\zeSID_PREFIX$')
endfunction

function! s:funcref(funcname)
  return function(s:SID_PREFIX() . a:funcname)
endfunction"}}}

" vim: foldmethod=marker
