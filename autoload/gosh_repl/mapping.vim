" Generated automatically DO NOT EDIT

function! gosh_repl#mapping#initialize()

  nnoremap <buffer><expr> <Plug>(gosh_change_line) <SID>change_line()

  nnoremap <buffer><silent> <Plug>(gosh_execute_line) :<C-u>call <SID>execute_line(0)<CR>
  nnoremap <buffer><silent> <Plug>(gosh_insert_head) :<C-u>call <SID>insert_head()<CR>
  nnoremap <buffer><silent> <Plug>(gosh_append_end) :<C-u>call <SID>append_end()<CR>
  nnoremap <buffer><silent> <Plug>(gosh_insert_enter) :<C-u>call <SID>insert_enter()<CR>
  nnoremap <buffer><silent> <Plug>(gosh_append_enter) :<C-u>call <SID>append_enter()<CR>
  nnoremap <buffer><silent> <Plug>(gosh_line_replace_history_prev) :<C-u>call <SID>line_replace_input_history(1)<CR>
  nnoremap <buffer><silent> <Plug>(gosh_line_replace_history_next) :<C-u>call <SID>line_replace_input_history(0)<CR>

  inoremap <buffer><silent> <Plug>(gosh_execute_line) <ESC>:<C-u>call <SID>execute_line(1)<CR>
  inoremap <buffer><expr> <Plug>(gosh_delete_backword_char) <SID>delete_backword_char()
  inoremap <buffer><expr> <Plug>(gosh_delete_backword_char) <SID>delete_backword_char()
  inoremap <buffer><expr> <Plug>(gosh_delete_backword_line) <SID>delete_backword_line()
  inoremap <buffer><silent> <Plug>(gosh_line_replace_history_prev) <ESC>:<C-u>call <SID>line_replace_input_history(1)<CR>:startinsert!<CR>
  inoremap <buffer><silent> <Plug>(gosh_line_replace_history_next) <ESC>:<C-u>call <SID>line_replace_input_history(0)<CR>:startinsert!<CR>

  if (exists("g:gosh_no_default_keymappings")) && g:gosh_no_default_keymappings
    return
  endif

  nmap <buffer> <CR> <Plug>(gosh_execute_line)
  nmap <buffer> cc <Plug>(gosh_change_line)
  nmap <buffer> dd <Plug>(gosh_change_line)<ESC>
  nmap <buffer> I <Plug>(gosh_insert_head)
  nmap <buffer> A <Plug>(gosh_append_end)
  nmap <buffer> i <Plug>(gosh_insert_enter)
  nmap <buffer> a <Plug>(gosh_append_enter)

  nmap <buffer> <C-p> <Plug>(gosh_line_replace_history_prev)
  nmap <buffer> <C-n> <Plug>(gosh_line_replace_history_next)

  imap <buffer> <CR> <Plug>(gosh_execute_line)
  imap <buffer> <BS> <Plug>(gosh_delete_backword_char)
  imap <buffer> <C-h> <Plug>(gosh_delete_backword_char)
  imap <buffer> <C-u> <Plug>(gosh_delete_backword_line)

  imap <buffer><silent> <C-p> <Plug>(gosh_line_replace_history_prev)
  imap <buffer><silent> <C-n> <Plug>(gosh_line_replace_history_next)

  vmap <buffer> <CR> <Plug>(gosh_repl_send_block)

endfunction

function! s:execute_line(is_insert)
  let bufnum_421 = bufnr("%")
  return gosh_repl#ui#execute(gosh_repl#get_line_text(gosh_repl#ui#get_context(bufnum_421),line(".")),bufnum_421,a:is_insert)
endfunction

function! s:change_line()
  let ctx_422 = gosh_repl#ui#get_context(bufnr("%"))
  if ctx_422 is 0
    return "ddO"
  endif
  let prompt_423 = gosh_repl#get_prompt(ctx_422,line("."))
  if empty(prompt_423)
    return "ddO"
  else
    return printf("0%dlc$",s:strchars(prompt_423))
  endif
endfunction

function! s:delete_backword_char()
  let ctx_424 = gosh_repl#ui#get_context(bufnr("%"))
  let prefix_425 = ((!(pumvisible()))?"" : ("\<C-y>"))
  let line_num_426 = line(".")
  if (len(getline(line_num_426))) > (len(gosh_repl#get_prompt(ctx_424,line_num_426)))
    return prefix_425 . ("\<BS>")
  else
    return prefix_425
  endif
endfunction

function! s:delete_backword_line()
  let prefix_427 = ((!(pumvisible()))?"" : ("\<C-y>"))
  let line_num_428 = line(".")
  let len_429 = (s:strchars(getline(line_num_428))) - (s:strchars(gosh_repl#get_prompt(gosh_repl#ui#get_context(bufnr("%")),line_num_428)))
  return prefix_427 . (repeat("\<BS>",len_429))
endfunction

function! s:insert_head()
  normal! 0
  return s:insert_enter()
endfunction

function! s:append_end()
  call s:insert_enter()
  startinsert!
endfunction

function! s:append_enter()
  if ((col(".")) + 1) == (col("$"))
    return s:append_end()
  else
    normal! l
    return s:insert_enter()
  endif
endfunction

function! s:insert_enter()
  let ctx_430 = gosh_repl#ui#get_context(bufnr("%"))
  let line_num_431 = line(".")
  let prompt_432 = gosh_repl#get_prompt(ctx_430,line_num_431)
  if (empty(prompt_432)) && (line_num_431 != (line("$")))
    startinsert
    return
  endif
  let prompt_len_433 = s:strchars(prompt_432)
  if (col(".")) <= prompt_len_433
    if (prompt_len_433 + 1) >= (col("$"))
      startinsert!
      return
    else
      let pos_434 = getpos(".")
      let pos_434[2] = prompt_len_433 + 1
      call setpos(".",pos_434)
    endif
  endif
  startinsert
endfunction

function! s:line_replace_input_history(prev)
  let ctx_435 = gosh_repl#ui#get_context(bufnr("%"))
  let lines_len_436 = len(ctx_435["lines"])
  if lines_len_436 == 0
    return
  endif
  let index_437 = ctx_435["_input_history_index"] + (((a:prev == 1)?1 : -1))
  if index_437 == 0
    let l:text = ""
  elseif index_437 > 0
    if index_437 <= lines_len_436
      let l:text = ctx_435["lines"][-index_437]
    elseif g:gosh_enable_ring_history
      let index_437 = 0
      let l:text = ""
    endif
  elseif g:gosh_enable_ring_history
    let index_437 = lines_len_436
    let l:text = ctx_435["lines"][-index_437]
  endif
  if exists("text")
    let line_num_438 = line(".")
    call setline(line_num_438,(gosh_repl#get_prompt(ctx_435,line_num_438)) . l:text)
    let ctx_435["_input_history_index"] = index_437
  endif
endfunction

function! s:strchars(str)
  return strlen(substitute(copy(a:str),".","x","g"))
endfunction

