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

if exists("loaded_gosh_repl")
  finish
endif
let loaded_gosh_repl = 1

let s:save_cpo = &cpo
set cpo&vim

let g:gosh_enable_auto_use = 
      \ get(g:, 'gosh_enable_auto_use', 0)

let g:gosh_updatetime = 
      \ get(g:, 'gosh_updatetime', 1000)

let g:gosh_buffer_width = 
      \ get(g:, 'gosh_buffer_width', 30)

let g:gosh_buffer_height = 
      \ get(g:, 'gosh_buffer_height', 15)

let g:gosh_buffer_direction = 
      \ get(g:, 'gosh_buffer_direction', 'h')


if executable("gosh")
  command! -nargs=0 GoshREPL :call gosh_repl#open_gosh_repl()
  command! -nargs=0 GoshREPLH :call gosh_repl#open_gosh_repl('h')
  command! -nargs=0 GoshREPLV :call gosh_repl#open_gosh_repl('v')

  command! -nargs=0 GoshREPLWithBuffer :call gosh_repl#open_gosh_repl_with_buffer()
  command! -nargs=0 GoshREPLWithBufferH :call gosh_repl#open_gosh_repl_with_buffer('h')
  command! -nargs=0 GoshREPLWithBufferV :call gosh_repl#open_gosh_repl_with_buffer('v')

  command! -nargs=1 GoshREPLSend :call gosh_repl#send_text(<q-args>)

  vnoremap <silent> <Plug>(gosh_repl_send_block) :call gosh_repl#send_text_block()<CR>
endif


let &cpo = s:save_cpo

