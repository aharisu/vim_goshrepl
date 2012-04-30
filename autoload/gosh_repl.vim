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

function! gosh_repl#create_gosh_context(...)"{{{
  let proc = vimproc#popen2('gosh -b'
        \ . ' -u gauche.interactive'
        \ . ' -e "(begin (read-eval-print-loop #f #f (lambda args (for-each print args)(flush)) (lambda () (display \"gosh> \")(flush)))(exit))"'
        \)
  
  "TODO check proc error

  let context = { 'proc' : proc,
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

function! gosh_repl#create_gosh_context_with_buf(bufnr, ...)"{{{
  let proc = vimproc#popen2('gosh -b'
        \ . ' -u gauche.interactive'
        \)

  let exception = 0
  
  "TODO check proc error

  try
    for line in getbufline(a:bufnr, 1, '$')
      call proc.stdin.write(line . "\n") 
    endfor

    call proc.stdin.write("(read-eval-print-loop #f #f (lambda args (for-each print args)(flush)) (lambda () (display \"gosh> \")(flush)))\n")
  catch
    echohl Error | echomsg join(proc.stdout.read_lines(), "\n") | echohl None

    let proc = vimproc#popen2('gosh -b'
          \ . ' -u gauche.interactive'
          \ . ' -e "(begin (read-eval-print-loop #f #f (lambda args (for-each print args)(flush)) (lambda () (display \"gosh> \")(flush)))(exit))"'
          \)
  endtry

  let context = { 'proc' : proc,
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
  call neocomplcache#print_warning('text:' . a:text)

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
    call s:insert_output(a:context, out)
  endif
endfunction"}}}

function! s:read_output(context, timeout)"{{{
  let out = ''
  let port = a:context.proc.stdout

  let res = port.read(-1, a:timeout)
  while !empty(res)
    let out .= res

    let res = port.read(-1, a:timeout)
  endwhile

  return out
endfunction"}}}

function! s:insert_output(context, out)"{{{
  if empty(a:out)
    return
  endif

  let col = col('.')
  let line = line('.')
  let cur_line_text = getline(line)

  let text_list = split(a:out, "\n")
  if a:out[-1] ==# "\n"
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
endfunction"}}}

function! gosh_repl#get_prompt(context, line)
  return has_key(a:context, 'prompt_histroy') ? 
        \ get(a:context.prompt_histroy, a:line, '') :
        \ ''
endfunction

" vim: foldmethod=marker
