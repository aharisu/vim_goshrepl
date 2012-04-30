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
  let bufnr = s:move_to_window('filetype', 'gosh-repl')

  if bufnr == 0
    silent! execute s:default_open_cmd
    enew
    let bufnr = bufnr('%')

    let context = gosh_repl#create_gosh_context(s:funcref('exit_callback'))
    let context.context__key = bufnr
    let context._input_history_index = 0
    let s:gosh_context[bufnr] = context

    call s:initialize_buffer()
    call gosh_repl#check_output(context, 50)

    "since a buffer number changed, it is a resetup.
    unlet s:gosh_context[bufnr]
    let bufnr = bufnr('%')
    let s:gosh_context[bufnr] = context
  else
    call cursor(line('$'), col('$'))
  endif

  startinsert!
endfunction"}}}

function! gosh_repl#ui#open_new_repl_with_buffer()"{{{
  let cur_bufnr = bufnr('%')

  silent! execute s:default_open_cmd
  enew
  let bufnr = bufnr('%')

  let context = gosh_repl#create_gosh_context_with_buf(cur_bufnr, s:funcref('exit_callback'))
  let context.context__key = bufnr
  let context._input_history_index = 0
  let s:gosh_context[bufnr] = context

  call s:initialize_buffer()
  call gosh_repl#check_output(context, 250)

  "since a buffer number changed, it is a resetup.
  unlet s:gosh_context[bufnr]
  let bufnr = bufnr('%')
  let s:gosh_context[bufnr] = context

  startinsert!
endfunction"}}}

function! s:exit_callback(context)"{{{
  execute a:context.context__key 'wincmd q'
  if has_key(s:gosh_context, a:context.context__key)
    unlet s:gosh_context[a:context.context__key]
  endif
endfunction"}}}

function! s:initialize_buffer()"{{{
  let cap = '[gosh REPL'

  let c = s:count_window('filetype', 'gosh-repl')
  if c != 0
    let cap .= '-' . (c + 1)
  endif
  let cap .= ']'

  edit `=cap`
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
  let gosh_repl_bufnr = s:find_buffer('filetype', 'gosh-repl')
  if gosh_repl_bufnr == 0
    echohl WarningMsg | echomsg 'use only in the GoshREPL buffer' | echohl None
  else
    let cur_nr = bufnr('%')
    if cur_nr != gosh_repl_bufnr
      call s:mark_back_to_window()
      call s:move_to_window('filetype', 'gosh-repl')
    endif

    % delete _

    let bufnr = bufnr('%')
    if has_key(s:gosh_context, bufnr)
      call gosh_repl#destry_gosh_context(s:gosh_context[bufnr])

      let context = gosh_repl#create_gosh_context(s:funcref('exit_callback'))
      let context.context__key = bufnr
      let s:gosh_context[bufnr] = context

      call gosh_repl#check_output(context, 50)
    endif

    if cur_nr != gosh_repl_bufnr
      call s:back_to_marked_window()
    endif
  endif
endfunction"}}}

function! gosh_repl#ui#execute(text, bufnr, is_insert)"{{{
  let context = gosh_repl#ui#get_context(a:bufnr)

  if bufnr('%') != a:bufnr
    call s:mark_back_to_window('_execute')
    execute a:bufnr 'wincmd w'
  endif

  call gosh_repl#execute_text(context, a:text)

  execute ":$ normal o"
  let line = line('.')
  let indent = lispindent(line)
  call setline(line, repeat(' ', indent) .  getline(line))

  call gosh_repl#check_output(context,66)

  let context._input_history_index = 0

  if bufnr('%') != a:bufnr
    call s:back_to_marked_window('_execute')
  elseif a:is_insert
    startinsert!
  endif
endfunction"}}}

function! gosh_repl#ui#send_text_block() range"{{{
  let v = visualmode()

  "get text of selected region
  let tmp = @@
  silent normal gvy
  let selected = @@
  let @@ = tmp

  if &filetype ==# 'gosh-repl'
    let text = ''
    let bufnr = bufnr('%')
    let context = gosh_repl#ui#get_context(bufnr)

    if v ==# 'v' || v ==# 'V'
      let line = a:firstline
      for line_text in map(split(selected, "\n"), "substitute(v:val, '^[	 ]*', '', '')")
        let prompt = gosh_repl#get_prompt(context, line)

        "chomp prompt
        if line_text =~# "^" . prompt
          let line_text = line_text[len(prompt) : ]
        endif

        let text .= ' ' . line_text

        let line += 1
      endfor
    else "^V rectangle selection
      let text = join(map(split(selected, "\n"), "substitute(v:val, '^[	 ]*', '', '')") , ' ')
    endif

  else
    let text = join(map(split(selected, "\n"), "substitute(v:val, '^[	 ]*', '', '')") , ' ')
  endif

  call gosh_repl#ui#send_text(text)
endfunction"}}}

function! gosh_repl#ui#send_text(text)"{{{
  let mode = mode()
  let filetype = &filetype

  if filetype !=# 'gosh-repl'
    call s:mark_back_to_window('send_text')
    call gosh_repl#ui#open_new_repl()
  endif

  call gosh_repl#ui#execute(a:text, bufnr('%'), 0)

  if filetype !=# 'gosh-repl'
    call s:back_to_marked_window('send_text')
  endif

  if mode ==# 'n'
    stopinsert
  endif
endfunction"}}}

function! gosh_repl#ui#show_all_line()"{{{
  let gosh_repl_bufnr = s:find_buffer('filetype', 'gosh-repl')
  if gosh_repl_bufnr == 0
    echohl WarningMsg | echomsg 'gosh-repl buffer not found.' | echohl None
  else
    let nr = s:move_to_window('let', 'gosh_repl_all_line')
    if nr == 0
      execute s:calc_split_window_direction(bufnr('%')) ' split'
      enew

      "buffer initialize
      edit `='[gosh REPL lines]'`
      setlocal buftype=nofile noswapfile
      setlocal bufhidden=delete
      setlocal filetype=scheme
      setlocal syntax=scheme

      "mark lines buffer 
      let b:gosh_repl_all_line = 1
    else
      % delete _
    endif

    let context = gosh_repl#ui#get_context(gosh_repl_bufnr)
    let line = 1
    for text in context.lines
      let indent = lispindent(line)
      call setline(line, repeat(' ', indent) . s:strtrim(text))
      let line += 1
      execute 'normal o'
      stopinsert
    endfor
    execute line 'delete _'
  endif
endfunction"}}}

function! s:calc_split_window_direction(bufnr)"{{{
  return winwidth(a:bufnr) * 2 < winheight(a:bufnr) * 5 ? '' : 'vertical'
endfunction"}}}

"
"window operation

function! s:count_window(kind, val)
  let c = 0

  for i in range(0, winnr('$'))
    let n = winbufnr(i)
    if a:kind ==# 'filetype'
      if getbufvar(n, '&filetype') ==# a:val
        let c += 1
      endif
    elseif a:kind ==# 'let'
      if getbufvar(n, a:val)
        let c += 1
      endif
    endif
  endfor

  return c
endfunction

function! s:move_to_window(kind, val)"{{{
  for i in range(0, winnr('$'))
    let n = winbufnr(i)
    let found = 0

    if a:kind ==# 'filetype'
      if getbufvar(n, '&filetype') ==# a:val
        let found = 1
      endif
    elseif a:kind ==# 'let'
      if getbufvar(n, a:val)
        let found = 1
      endif
    endif

    if found
      if i != 0
        execute i 'wincmd w'
      endif
      return n
    endif
  endfor

  return 0
endfunction"}}}

function! s:find_buffer(kind, val)"{{{
  for i in range(0, winnr('$'))
    let n = winbufnr(i)

    let found = 0
    if a:kind ==# 'filetype'
      if getbufvar(n, '&filetype') ==# a:val
        let found = 1
      endif
    elseif a:kind ==# 'let'
      if getbufvar(n, a:val)
        let found = 1
      endif
    endif

    if found
      return n
    endif
  endfor

  return 0
endfunction"}}}

function! s:mark_back_to_window(...)"{{{
  let mark = a:0 > 0 ? a:1 : 'ref_back'
  execute 'let w:' . mark . ' = 1'
endfunction"}}}

function! s:unmark_back_to_window()"{{{
  unlet! w:ref_back
endfunction"}}}

function! s:back_to_marked_window(...)"{{{
  let mark = a:0 > 0 ? a:1 : 'ref_back'

  for t in range(1, tabpagenr('$'))
    for w in range(1, winnr('$'))
      if gettabwinvar(t, w, mark)
        execute 'tabnext' t
        execute w 'wincmd w'
        execute 'unlet! w:' . mark
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

function! s:strtrim(text)"{{{
  return substitute(copy(a:text), '^\s*', '', '')
endfunction"}}}

" vim: foldmethod=marker
