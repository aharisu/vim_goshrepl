"=============================================================================
" FILE: mapping.vim
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

function! gosh_repl#mapping#initialize()
  nnoremap <buffer><expr> <Plug>(change_line) <SID>change_line()

  nnoremap <buffer><silent> <CR> 
        \:<C-u>call <SID>execute_line(0)<CR>
  nmap <buffer> cc <Plug>(change_line)
  nmap <buffer> dd <Plug>(change_line)<ESC>
  nmap <buffer> I :<C-u>call <SID>insert_head()<CR>
  nmap <buffer> A :<C-u>call <SID>append_end()<CR>
  nmap <buffer> i :<C-u>call <SID>insert_enter()<CR>
  nmap <buffer> a :<C-u>call <SID>append_enter()<CR>

  inoremap <buffer><silent> <CR> 
        \ <ESC>:<C-u>call <SID>execute_line(1)<CR>
  inoremap <buffer><expr> <BS> <SID>delete_backword_char()
  inoremap <buffer><expr> <C-h> <SID>delete_backword_char()
  inoremap <buffer><expr> <C-u> <SID>delete_backword_line()
endfunction

function! s:execute_line(is_insert)"{{{
  let context = gosh_repl#ui#get_context(bufnr('%'))
  call gosh_repl#execute_line(context)

  execute "normal o"
  let line = line('.')
  let indent = lispindent(line)
  call setline(line, repeat(' ', indent) .  getline(line))

  call gosh_repl#check_output(context,66)

  if a:is_insert
    startinsert!
  endif
endfunction"}}}

function! s:change_line()"{{{
  let context = gosh_repl#ui#get_context(bufnr('%'))
  if context is 0
    return 'ddO'
  endif

  let prompt = gosh_repl#get_prompt(context, line('.'))
  if empty(prompt)
    return 'ddO'
  else
    return printf('0%dlc$', s:strchars(prompt))
  endif
endfunction"}}}

function! s:delete_backword_char()"{{{
  let context = gosh_repl#ui#get_context(bufnr('%'))

  if !pumvisible()
    let prefix = ''
  else
    let prefix = "\<C-y>"
  endif

  let line_num = line('.')
  let line = getline(line_num)
  if len(line) > len(gosh_repl#get_prompt(context, line_num))
    return prefix . "\<BS>"
  else
    return prefix
  endif
endfunction"}}}

function! s:delete_backword_line()"{{{
  if !pumvisible()
    let prefix = ''
  else
    let prefix = "\<C-y>"
  endif

  let line_num = line('.')
  let len = s:strchars(getline(line_num)) - 
        \ s:strchars(gosh_repl#get_prompt(gosh_repl#ui#get_context(bufnr('%')), line_num))

  return prefix . repeat("\<BS>", len)
endfunction"}}}


function! s:insert_head()"{{{
  normal! 0
  call s:insert_enter()
endfunction"}}}

function! s:append_end()"{{{
  call s:insert_enter()
  startinsert!
endfunction"}}}

function! s:append_enter()"{{{
  if col('.') + 1 == col('$')
    call s:append_end()
  else
    normal! l
    call s:insert_enter()
  endif
endfunction"}}}

function! s:insert_enter()"{{{
  let context = gosh_repl#ui#get_context(bufnr('%'))

  let line_num = line('.')
  let prompt = gosh_repl#get_prompt(context, line_num)
  if empty(prompt) && line_num != line('$')
    startinsert
    return
  endif

  let prompt_len = s:strchars(prompt)
  if col('.') <= prompt_len
    if prompt_len + 1 >= col('$')
      startinsert!
      return
    else
      let pos = getpos('.')
      let pos[2] = prompt_len + 1
      call setpos('.', pos)
    endif
  endif

  startinsert
endfunction"}}}


"
"Util

"from vital.vim plugin s:strchars"{{{
function! s:strchars(str)
  return strlen(substitute(copy(a:str), '.', 'x', 'g'))
endfunction"}}}

" vim: foldmethod=marker
