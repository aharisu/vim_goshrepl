"=============================================================================
" FILE: gosh_repl.vim
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

let s:gosh_repl_directory = substitute(expand('<sfile>:p:h'), '\\', '/', 'g')
let s:gosh_repl_body_path = s:gosh_repl_directory . '/gosh_repl/repl.scm'

function! s:enable_auto_use_exp()
  if g:gosh_enable_auto_use
    return '(define *enable-auto-use* #t)'
  else
    return '(define *enable-auto-use* #f)'
  endif
endfunction

function! gosh_repl#create_gosh_context(Printer, ...)"{{{
  let proc = vimproc#popen2('gosh -b'
        \ . ' -u gauche.interactive'
        \ . ' -I' . s:gosh_repl_directory . '/gosh_repl/'
        \ . ' -e "(begin ' . s:enable_auto_use_exp() . ' (include \"' . s:gosh_repl_body_path . '\") (exit))"'
        \)
  
  "TODO check proc error

  let context = { 'proc' : proc,
        \ 'printer' : a:Printer,
        \ 'lines' : [],
        \ 'prompt_histroy' : {},
        \ }

  if a:0 > 0
    let context.exit_callback = a:1
  else
    let context.exit_callback = 0
  endif

  return context
endfunction"}}}

function! gosh_repl#create_gosh_context_with_buf(Printer, bufnr, ...)"{{{
  let proc = vimproc#popen2('gosh -b'
        \ . ' -u gauche.interactive'
        \ . ' -I' . s:gosh_repl_directory . '/gosh_repl/'
        \)

  "TODO check proc error

  let exception = 0
  try
    for line in getbufline(a:bufnr, 1, '$')
      call proc.stdin.write(line . "\n") 
    endfor

    sleep 100ms
    call proc.stdin.write("(begin " . s:enable_auto_use_exp() . " (include \"" . s:gosh_repl_body_path . "\"))\n")
  catch
    let exception = 1
  endtry

  sleep 100ms
  if !proc.is_valid || !proc.stdin.is_valid || proc.stdin.eof || !proc.stdout.is_valid || proc.stdout.eof
    let exception = 1
  endif

  if exception
    echohl Error | echomsg join(proc.stdout.read_lines(), "\n") | echohl None
    let proc = vimproc#popen2('gosh -b'
          \ . ' -u gauche.interactive'
          \ . ' -I' . s:gosh_repl_directory . '/gosh_repl/'
          \ . ' -e "(begin ' . s:enable_auto_use_exp() . ' (include \"' . s:gosh_repl_body_path . '\") (exit))"'
          \)
  endif

  let context = { 'proc' : proc,
        \ 'printer' : a:Printer,
        \ 'lines' : [],
        \ 'prompt_histroy' : {},
        \ }

  if a:0 > 0
    let context.exit_callback = a:1
  else
    let context.exit_callback = 0
  endif

  return context
endfunction"}}}

function! gosh_repl#destry_gosh_context(context)"{{{
  call a:context.proc.stdin.close()
  call a:context.proc.stdout.close()
  call s:run_exit_callback(a:context)
endfunction"}}}

function! s:run_exit_callback(context)
  if a:context.exit_callback isnot 0
    let Exit_callback = a:context.exit_callback
    call Exit_callback(a:context)
  endif
endfunction

function! gosh_repl#execute_line(context)"{{{
  let line = line('.')
  call gosh_repl#execute_text(a:context, gosh_repl#get_line_text(a:context, line))
endfunction"}}}

function! gosh_repl#get_line_text(context, num_line)"{{{
  let line = getline(a:num_line)

  return line[len(gosh_repl#get_prompt(a:context, a:num_line)) : ]
endfunction"}}}

function! gosh_repl#execute_text(context, text)"{{{
  if !a:context.proc.is_valid || !a:context.proc.stdin.is_valid || a:context.proc.stdin.eof
    call s:run_exit_callback(a:context)
    return 
  endif

  "TODO how do I handle the empty line
  call add(a:context.lines, a:text)

  if a:text !~# "\n$"
    let text = a:text . "\n"
  else
    let text = a:text
  endif

  call a:context.proc.stdin.write(text)
endfunction"}}}

function! gosh_repl#check_output(context, ...)"{{{
  if !a:context.proc.is_valid || !a:context.proc.stdout.is_valid || a:context.proc.stdout.eof
    call s:run_exit_callback(a:context)
    return 
  endif

  let timeout = a:0 > 0 ? a:1 : 0

  let out = s:read_output(a:context, timeout)
  if !empty(out)
    let Printer = a:context.printer
    call Printer(a:context, out)
  endif
endfunction"}}}

function! s:read_output(context, timeout)"{{{
  let out = ''
  let port = a:context.proc.stdout

  let res = port.read(-1, a:timeout)
  while !empty(res)
    let out .= res

    let res = port.read(-1, 15)
  endwhile

  return out
endfunction"}}}

function! gosh_repl#get_prompt(context, line)
  return has_key(a:context, 'prompt_histroy') ? 
        \ get(a:context.prompt_histroy, a:line, '') :
        \ ''
endfunction

" vim: foldmethod=marker
