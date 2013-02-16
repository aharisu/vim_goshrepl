" Generated automatically DO NOT EDIT

function! ieie_mapping#initialize()

  nnoremap <buffer><expr> <Plug>(ieie_change_line) <SID>change_line()

  nnoremap <buffer><silent> <Plug>(ieie_execute_line) :<C-u>call <SID>execute_line(0)<CR>
  nnoremap <buffer><silent> <Plug>(ieie_insert_head) :<C-u>call <SID>insert_head()<CR>
  nnoremap <buffer><silent> <Plug>(ieie_append_end) :<C-u>call <SID>append_end()<CR>
  nnoremap <buffer><silent> <Plug>(ieie_insert_enter) :<C-u>call <SID>insert_enter()<CR>
  nnoremap <buffer><silent> <Plug>(ieie_append_enter) :<C-u>call <SID>append_enter()<CR>
  nnoremap <buffer><silent> <Plug>(ieie_line_replace_history_prev) :<C-u>call <SID>line_replace_input_history(1)<CR>
  nnoremap <buffer><silent> <Plug>(ieie_line_replace_history_next) :<C-u>call <SID>line_replace_input_history(0)<CR>

  inoremap <buffer><silent> <Plug>(ieie_execute_line) <ESC>:<C-u>call <SID>execute_line(1)<CR>
  inoremap <buffer><expr> <Plug>(ieie_delete_backword_char) <SID>delete_backword_char()
  inoremap <buffer><expr> <Plug>(ieie_delete_backword_char) <SID>delete_backword_char()
  inoremap <buffer><expr> <Plug>(ieie_delete_backword_line) <SID>delete_backword_line()
  inoremap <buffer><silent> <Plug>(ieie_line_replace_history_prev) <ESC>:<C-u>call <SID>line_replace_input_history(1)<CR>:startinsert!<CR>
  inoremap <buffer><silent> <Plug>(ieie_line_replace_history_next) <ESC>:<C-u>call <SID>line_replace_input_history(0)<CR>:startinsert!<CR>


  nmap <buffer> <CR> <Plug>(ieie_execute_line)
  nmap <buffer> cc <Plug>(ieie_change_line)
  nmap <buffer> dd <Plug>(ieie_change_line)<ESC>
  nmap <buffer> I <Plug>(ieie_insert_head)
  nmap <buffer> A <Plug>(ieie_append_end)
  nmap <buffer> i <Plug>(ieie_insert_enter)
  nmap <buffer> a <Plug>(ieie_append_enter)

  nmap <buffer> <C-p> <Plug>(ieie_line_replace_history_prev)
  nmap <buffer> <C-n> <Plug>(ieie_line_replace_history_next)

  imap <buffer> <CR> <Plug>(ieie_execute_line)
  imap <buffer> <BS> <Plug>(ieie_delete_backword_char)
  imap <buffer> <C-h> <Plug>(ieie_delete_backword_char)
  imap <buffer> <C-u> <Plug>(ieie_delete_backword_line)

  imap <buffer><silent> <C-p> <Plug>(ieie_line_replace_history_prev)
  imap <buffer><silent> <C-n> <Plug>(ieie_line_replace_history_next)

  vmap <buffer> <CR> <Plug>(ieie_repl_send_block)

endfunction

function! s:execute_line(is_insert)
  let bufnum_468 = bufnr("%")
  return ieie#execute(ieie#get_line_text(ieie#get_context(bufnum_468),line(".")),bufnum_468,a:is_insert)
endfunction

function! s:change_line()
  let ctx_469 = ieie#get_context(bufnr("%"))
  if ctx_469 is 0
    return "ddO"
  endif
  let prompt_470 = ieie#get_prompt(ctx_469,line("."))
  if empty(prompt_470)
    return "ddO"
  else
    return printf("0%dlc$",s:strchars(prompt_470))
  endif
endfunction

function! s:delete_backword_char()
  let ctx_471 = ieie#get_context(bufnr("%"))
  let prefix_472 = ((!(pumvisible()))?"" : ("\<C-y>"))
  let line_num_473 = line(".")
  if (len(getline(line_num_473))) > (len(ieie#get_prompt(ctx_471,line_num_473)))
    return prefix_472 . ("\<BS>")
  else
    return prefix_472
  endif
endfunction

function! s:delete_backword_line()
  let prefix_474 = ((!(pumvisible()))?"" : ("\<C-y>"))
  let line_num_475 = line(".")
  let len_476 = (s:strchars(getline(line_num_475))) - (s:strchars(ieie#get_prompt(ieie#get_context(bufnr("%")),line_num_475)))
  return prefix_474 . (repeat("\<BS>",len_476))
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
  let ctx_477 = ieie#get_context(bufnr("%"))
  let line_num_478 = line(".")
  let prompt_479 = ieie#get_prompt(ctx_477,line_num_478)
  if (empty(prompt_479)) && (line_num_478 != (line("$")))
    startinsert
    return
  endif
  let prompt_len_480 = s:strchars(prompt_479)
  if (col(".")) <= prompt_len_480
    if (prompt_len_480 + 1) >= (col("$"))
      startinsert!
      return
    else
      let pos_481 = getpos(".")
      let pos_481[2] = prompt_len_480 + 1
      call setpos(".",pos_481)
    endif
  endif
  startinsert
endfunction

function! s:line_replace_input_history(prev)
  let ctx_482 = ieie#get_context(bufnr("%"))
  let lines_len_483 = len(ctx_482["lines"])
  if lines_len_483 == 0
    return
  endif
  let index_484 = ctx_482["input-history-index"] + (((a:prev == 1)?1 : -1))
  if index_484 == 0
    let l:text = ""
  elseif index_484 > 0
    if index_484 <= lines_len_483
      let l:text = ctx_482["lines"][-index_484]
    else
      let index_484 = 0
      let l:text = ""
    endif
  else
    let index_484 = lines_len_483
    let l:text = ctx_482["lines"][-index_484]
  endif
  if exists("text")
    let line_num_485 = line(".")
    call setline(line_num_485,(ieie#get_prompt(ctx_482,line_num_485)) . l:text)
    let ctx_482["input-history-index"] = index_484
  endif
endfunction

function! s:strchars(str)
  return strlen(substitute(copy(a:str),".","x","g"))
endfunction

