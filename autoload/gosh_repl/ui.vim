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

let s:updatetime_save = &updatetime
let b:lispwords = ''

function! gosh_repl#ui#open_new_repl(...)"{{{
  let bufnr = s:move_to_window('filetype', 'gosh-repl')

  if bufnr == 0
    silent! execute s:get_buffer_open_cmd(
          \ 0 < a:0 ? a:1 : g:gosh_buffer_direction)
    enew
    let bufnr = bufnr('%')

    let context = gosh_repl#create_gosh_context(
          \ s:funcref('insert_output'), s:funcref('exit_callback'))
    call s:initialize_context(bufnr, context)

    call s:initialize_buffer()
    call gosh_repl#check_output(context, 250)

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

  silent! execute s:get_buffer_open_cmd(
        \ 0 < a:0 ? a:1 : g:gosh_buffer_direction)
  enew
  let bufnr = bufnr('%')

  let context = gosh_repl#create_gosh_context_with_buf(
        \ s:funcref('insert_output'), cur_bufnr, s:funcref('exit_callback'))
  call s:initialize_context(bufnr, context)

  call s:initialize_buffer()
  call gosh_repl#check_output(context, 250)

  "since a buffer number changed, it is a resetup.
  unlet s:gosh_context[bufnr]
  let bufnr = bufnr('%')
  let s:gosh_context[bufnr] = context

  startinsert!
endfunction"}}}

function! s:get_buffer_open_cmd(direc)
  if a:direc =~# '^v'
    return g:gosh_buffer_width . ':vs'
  else
    return g:gosh_buffer_height . ':sp'
  endif
endfunction

function! s:initialize_context(bufnr, context)"{{{
  let a:context.context__bufnr = a:bufnr
  let a:context._input_history_index = 0
  let a:context.context__is_buf_closed = 0

  let s:gosh_context[a:bufnr] = a:context
endfunction"}}}

function! s:exit_callback(context)"{{{
  if !a:context.context__is_buf_closed
    execute a:context.context__bufnr 'wincmd q'
  endif

  if has_key(s:gosh_context, a:context.context__bufnr)
    unlet s:gosh_context[a:context.context__bufnr]
  endif

  if len(s:gosh_context) == 0
    augroup goshrepl-plugin
      autocmd! *
    augroup END
  endif

  call s:buf_leave()
endfunction"}}}

function! s:insert_output(context, text)"{{{
  if empty(a:text)
    return
  endif

  let cur_bufnr = bufnr('%')

  if cur_bufnr != a:context.context__bufnr
    call s:mark_back_to_window('_output')
    call s:move_to_buffer(a:context.context__bufnr)
  endif

  let col = col('.')
  let line = line('.')
  let cur_line_text = getline(line)

  let text_list = split(a:text, "\n")
  if a:text[-1] ==# "\n"
    let prompt = ''
    call add(text_list, cur_line_text)
  else
    let prompt = text_list[-1]

    let col += len(prompt)
    let text_list[-1] .= cur_line_text
  endif

  for text in text_list
    call setline(line, text)

    let line += 1
  endfor
  let line -= 1

  if !empty(prompt)
    let a:context.prompt_histroy[line] = prompt
  endif

  call cursor(line, col)
  "for screen update ...
  call winline()

  if cur_bufnr != a:context.context__bufnr
    call s:back_to_marked_window('_output')
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

  augroup goshrepl-plugin
    autocmd BufUnload <buffer> call s:unload_buffer()
    autocmd BufEnter <buffer> call s:buf_enter()
    autocmd BufLeave <buffer> call s:buf_leave()
    autocmd CursorHold * call s:cursor_hold('n')
    autocmd CursorHoldI * call s:cursor_hold('i')
    autocmd CursorMoved * call s:check_output(0)
    autocmd CursorMovedI * call s:check_output(0)

  augroup END

  call s:buf_enter()

  call gosh_repl#mapping#initialize()

endfunction"}}}

function! gosh_repl#ui#get_context(bufnr)"{{{
  return s:gosh_context[a:bufnr]
endfunction"}}}

function! s:unload_buffer()"{{{
  if has_key(s:gosh_context, bufnr('%'))
    let context = s:gosh_context[bufnr('%')] 
    let context.context__is_buf_closed = 1

    call gosh_repl#destry_gosh_context(context)
  endif
endfunction"}}}

function! s:cursor_hold(mode)"{{{
  call s:check_output(0)

  if a:mode ==# 'n'
    call feedkeys("g\<ESC>", 'n')
  elseif a:mode ==# 'i'
    call feedkeys("a\<BS>", 'n')
  endif
endfunction"}}}

function! s:check_output(timeout)"{{{
  for context in values(s:gosh_context)
    call gosh_repl#check_output(context, a:timeout)
  endfor
endfunction"}}}

function! s:buf_enter()"{{{
  call s:save_updatetime()

  let b:lispwords = &lispwords
  let &lispwords = 'lambda,and,or,if,cond,case,define,let,let*,letrec,begin,do,delay,set!,else,=>,quote,quasiquote,unquote,unquote-splicing,define-syntax,let-syntax,letrec-syntax,syntax-rules,%macroexpand,%macroexpand-1,and-let*,current-module,define-class,define-constant,define-generic,define-in-module,define-inline,define-macro,define-method,define-module,eval-when,export,export-all,extend,import,include,lazy,receive,require,select-module,unless,when,with-module,$,$*,$<<,$do,$do*,$lazy,$many-chars,$or,$satisfy,%do-ec,%ec-guarded-do-ec,%first-ec,%guard-rec,%replace-keywords,--,^,^*,^-generator,^.,^_,^a,^b,^c,^d,^e,^f,^g,^h,^i,^j,^k,^l,^m,^n,^o,^p,^q,^r,^s,^t,^u,^w,^v,^x,^y,^z,add-load-path,any?-ec,append-ec,apropos,assert,autoload,begin0,case-lambda,check-arg,cond-expand,cond-list,condition,cut,cute,debug-print,dec!,declare,define-^x,define-cgen-literal,define-cise-expr,define-cise-macro,define-cise-stmt,define-cise-toplevel,define-compiler-macro,define-condition-type,define-record-type,define-values,do-ec,do-ec:do,dolist,dotimes,ec-guarded-do-ec,ec-simplify,every?-ec,export-if-defined,first-ec,fluid-let,fold-ec,fold3-ec,get-keyword*,get-optional,guard,http-cond-receiver,if-let1,inc!,inline-stub,last-ec,let*-values,let-args,let-keywords,let-keywords*,let-optionals*,let-string-start+end,let-values,let/cc,let1,list-ec,make-option-parser,match,match-define,match-lambda,match-lambda*,match-let,match-let*,match-let1,match-letrec,max-ec,min-ec,parameterize,parse-options,pop!,product-ec,program,push!,rec,require-extension,reset,rlet1,rxmatch-case,rxmatch-cond,rxmatch-if,rxmatch-let,set!-values,shift,srfi-42-,srfi-42-char-range,srfi-42-dispatched,srfi-42-do,srfi-42-generator-proc,srfi-42-integers,srfi-42-let,srfi-42-list,srfi-42-parallel,srfi-42-parallel-1,srfi-42-port,srfi-42-range,srfi-42-real-range,srfi-42-string42-until-1,srfi-42-untilfi-42-vectorfi-42-while-1srfi-42-whilefi-42-while-2ax:make-parserssax:make-elem-parser,stream-cons,ssax:make-pi-parsertream-delay,string-append-ec,string-ec,sum-ec,sxml:find-name-separator,syntax-errorx-errorfime,test*,until,unwind-protect,update!,use,use-version,values-ref,vector-ec,vector-of-length-ec,while,with-builder,with-iteratorwith-signal-handlers,with-time-counter,xmac,xmac1'
endfunction "}}}

function! s:buf_leave() "{{{
  call s:restore_updatetime()

  if !empty(b:lispwords)
    let &lispwords = b:lispwords
    let b:lispwords = ''
  endif
endfunction"}}}

function! s:save_updatetime()"{{{
  let s:updatetime_save = &updatetime

  if &updatetime > g:gosh_updatetime
    let &updatetime = g:gosh_updatetime
  endif
endfunction"}}}

function! s:restore_updatetime()"{{{
  if &updatetime < s:updatetime_save
    let &updatetime = s:updatetime_save
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
      let context.context__bufnr = bufnr
      let s:gosh_context[bufnr] = context

      call gosh_repl#check_output(context, 150)
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
    call s:move_to_buffer(a:bufnr)
  endif

  call gosh_repl#execute_text(context, a:text)

  execute ":$ normal o"
  let line = line('.')
  let indent = lispindent(line)
  call setline(line, repeat(' ', indent) .  getline(line))

  call gosh_repl#check_output(context, 100)

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

function! s:count_window(kind, val)"{{{
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
endfunction"}}}

function! s:move_to_buffer(bufnr)
  for i in range(0, winnr('$'))
    let n = winbufnr(i)
    let found = 0

    if a:bufnr == n
      let found = 1
    endif

    if found
      if i != 0
        execute i 'wincmd w'
      endif
      return n
    endif
  endfor

  return 0
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
