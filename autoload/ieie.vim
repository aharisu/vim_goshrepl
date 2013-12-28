" Generated automatically DO NOT EDIT

function! s:SID_PREFIX_484()
  return matchstr(expand('<sfile>'),'<SNR>\d\+_\zeSID_PREFIX_484$')
endfunction

let s:dict_type_482 = type({})

let s:str_type = type("")

function! s:get_proc(conf)
  let Proc_481 = get(a:conf,"proc",0)
  if Proc_481 isnot 0
    if (type(Proc_481)) == s:str_type
      if has_key(a:conf,"stderr-printer")
        if get(a:conf,"pty",0)
          return vimproc#ptyopen(Proc_481,3)
        else
          return vimproc#popen3(Proc_481)
        endif
      elseif get(a:conf,"pty",0)
        return vimproc#ptyopen(Proc_481,2)
      else
        return vimproc#popen2(Proc_481)
      endif
    else
      return (type(Proc_481)==s:dict_type_482) ? Proc_481.func() : Proc_481()
    endif
  else
    return 0
  endif
endfunction

function! s:get_filetype(conf)
  return get(a:conf,"filetype","None")
endfunction

function! s:get_syntax(conf)
  if has_key(a:conf,"syntax")
    return a:conf["syntax"]
  else
    return s:get_filetype(a:conf)
  endif
endfunction

function! s:get_caption(conf)
  return get(a:conf,"caption","ieie")
endfunction

function! s:get_mark(conf)
  if has_key(a:conf,"mark")
    return a:conf["mark"]
  else
    return substitute(substitute(s:get_caption(a:conf)," ","_","g"),"-","_","g")
  endif
endfunction

function! s:get_buffer_open_cmd(conf)
  let Cmd_483 = get(a:conf,"buffer-open","15:sp")
  if (type(Cmd_483)) == s:str_type
    return Cmd_483
  else
    return (type(Cmd_483)==s:dict_type_482) ? Cmd_483.func(a:conf) : Cmd_483(a:conf)
  endif
endfunction

function! s:create_context(conf)
  return {'proc' : s:get_proc(a:conf),'pty' : get(a:conf,"pty",0),'stdout-printer' : get(a:conf,"stdout-printer",function(s:SID_PREFIX_484() . 'default_printer')),'stderr-printer' : ((has_key(a:conf,"stderr-printer"))?(((a:conf["stderr-printer"] isnot 0)?a:conf["stderr-printer"] : function(s:SID_PREFIX_484() . 'default_printer'))) : 0),'exit-callback' : get(a:conf,"exit-callback",0),'buffer-enter' : get(a:conf,"buffer-enter",0),'buffer-leave' : get(a:conf,"buffer-leave",0),'lines' : [],'prompt-history' : {},'stdout-remain' : "",'stderr-reamin' : "",'stdout-reader' : ((has_key(a:conf,"stdout-read-line?"))?(((a:conf["stdout-read-line?"])?function(s:SID_PREFIX_484() . 'read_output_lines') : function(s:SID_PREFIX_484() . 'read_output'))) : function(s:SID_PREFIX_484() . 'read_output')),'stderr-reader' : ((has_key(a:conf,"stderr-read-line?"))?(((a:conf["stderr-read-line?"])?function(s:SID_PREFIX_484() . 'read_output_lines') : function(s:SID_PREFIX_484() . 'read_output'))) : function(s:SID_PREFIX_484() . 'read_output'))}
endfunction

function! s:destry_context(ctx)
  if (type(a:ctx["proc"]["stdin"]["close"])==s:dict_type_482)
    call a:ctx["proc"]["stdin"]["close"].func()
  else
    call a:ctx["proc"]["stdin"]["close"]()
  endif
  if (type(a:ctx["proc"]["stdout"]["close"])==s:dict_type_482)
    call a:ctx["proc"]["stdout"]["close"].func()
  else
    call a:ctx["proc"]["stdout"]["close"]()
  endif
  return s:run_exit_callback(a:ctx)
endfunction

function! s:run_exit_callback(ctx)
  call s:buffer_leave()
  let Exit_485 = a:ctx["exit-callback"]
  if Exit_485 isnot 0
    if (type(Exit_485)==s:dict_type_482)
      call Exit_485.func(a:ctx)
    else
      call Exit_485(a:ctx)
    endif
  endif
  return s:finalize_interactive(a:ctx)
endfunction

function! ieie#get_line_text(ctx,num_line)
  return getline(a:num_line)[len(ieie#get_prompt(a:ctx,a:num_line)):]
endfunction

function! ieie#execute_text(ctx,text)
  if (!a:ctx["proc"]["is_valid"]) || (!a:ctx["proc"]["stdin"]["is_valid"]) || a:ctx["proc"]["stdin"]["eof"]
    return s:run_exit_callback(a:ctx)
  else
    call add(a:ctx["lines"],a:text)
    return (type(a:ctx["proc"]["stdin"]["write"])==s:dict_type_482) ? a:ctx["proc"]["stdin"]["write"].func(((a:text !~# "\n$")?a:text . "\n" : a:text)) : a:ctx["proc"]["stdin"]["write"](((a:text !~# "\n$")?a:text . "\n" : a:text))
  endif
endfunction

function! ieie#check_output(ctx,...)
  if (!a:ctx["proc"]["is_valid"]) || (!a:ctx["proc"]["stdout"]["is_valid"]) || a:ctx["proc"]["stdout"]["eof"]
    return s:run_exit_callback(a:ctx)
  else
    let outputP_486 = 0
    let Printer_487 = a:ctx["stderr-printer"]
    if Printer_487 isnot 0
      let [out_488,remain_489] = (type(a:ctx["stderr-reader"])==s:dict_type_482) ? a:ctx["stderr-reader"].func(a:ctx["proc"]["stderr"],get(a:000,0,0),a:ctx["stderr-remain"]) : a:ctx["stderr-reader"](a:ctx["proc"]["stderr"],get(a:000,0,0),a:ctx["stderr-remain"])
      let a:ctx["stderr-remain"] = remain_489
      if !(empty(out_488))
        if (type(Printer_487)==s:dict_type_482)
          call Printer_487.func(a:ctx,out_488)
        else
          call Printer_487(a:ctx,out_488)
        endif
      endif
    endif
    let Printer_490 = a:ctx["stdout-printer"]
    if Printer_490 isnot 0
      let [out_491,remain_492] = (type(a:ctx["stdout-reader"])==s:dict_type_482) ? a:ctx["stdout-reader"].func(a:ctx["proc"]["stdout"],get(a:000,0,0),a:ctx["stdout-remain"]) : a:ctx["stdout-reader"](a:ctx["proc"]["stdout"],get(a:000,0,0),a:ctx["stdout-remain"])
      let a:ctx["stdout-remain"] = remain_492
      if !(empty(out_491))
        let outputP_486 = 1
        if (type(Printer_490)==s:dict_type_482)
          call Printer_490.func(a:ctx,out_491)
        else
          call Printer_490(a:ctx,out_491)
        endif
      endif
    endif
    return outputP_486
  endif
endfunction

function! s:read_output(port,timeout,remain)
  let out_493 = ""
  let res_494 = a:remain . ((type(a:port["read"])==s:dict_type_482) ? a:port["read"].func(-1,a:timeout) : a:port["read"](-1,a:timeout))
  let recursion_495 = 1
  while recursion_495
    let recursion_495 = 0
    if empty(res_494)
      return [out_493,""]
    else
      let recursion_495 = 1
      let out_493 = out_493 . res_494
      let res_494 = (type(a:port["read"])==s:dict_type_482) ? a:port["read"].func(-1,15) : a:port["read"](-1,15)
    endif
  endwhile
endfunction

function! s:read_output_lines(port,timeout,remain)
  let out_496 = ""
  let res_497 = a:remain . ((type(a:port["read"])==s:dict_type_482) ? a:port["read"].func(-1,a:timeout) : a:port["read"](-1,a:timeout))
  let recursion_498 = 1
  while recursion_498
    let recursion_498 = 0
    if empty(res_497)
      let index_499 = strridx(out_496,"\n")
      if index_499 < 0
        return ["",out_496]
      elseif index_499 != 0
        return [out_496[0:index_499 - 1],out_496[index_499 + 1:]]
      else
        return ["",out_496[index_499 + 1:]]
      endif
    else
      let recursion_498 = 1
      let out_496 = out_496 . res_497
      let res_497 = (type(a:port["read"])==s:dict_type_482) ? a:port["read"].func(512,100) : a:port["read"](512,100)
    endif
  endwhile
endfunction

function! s:get_newline_mark(text)
  let idx_500 = stridx(a:text,"\r")
  if -1 == idx_500
    return "\n"
  elseif a:text[idx_500 + 1] == "\n"
    return "\r\n"
  else
    return "\r"
  endif
endfunction

function! s:line_split(text)
  return split(a:text,s:get_newline_mark(a:text))
endfunction

function! s:get_user_input_text_26output_text_list(ctx,line,text)
  let prompt_501 = ieie#get_prompt(a:ctx,a:line)
  let line_text_502 = getline(a:line)
  let user_input_text_503 = line_text_502[(stridx(line_text_502,prompt_501)) + (len(prompt_501)):]
  let text_list_504 = s:line_split(a:text)
  if !(empty(prompt_501))
    if 0 == (len(text_list_504))
      call add(text_list_504,prompt_501)
    else
      let text_list_504[0] = prompt_501 . text_list_504[0]
    endif
  endif
  return [user_input_text_503,text_list_504]
endfunction

function! s:default_printer(ctx,text)
  if empty(a:text)
    return
  endif
  let bufnum_505 = bufnr("%")
  if bufnum_505 != a:ctx["bufnr"]
    let l:changebuf = 1
    call ieie#mark_back_to_window("switch476")
    call ieie#move_to_buffer(a:ctx["bufnr"])
  endif
  let col_506 = col(".")
  let line_507 = line(".")
  let [user_input_text_508,text_list_509] = s:get_user_input_text_26output_text_list(a:ctx,line_507,a:text)
  let prompt_510 = ""
  if a:text[-1] ==# "\n"
    call add(text_list_509,user_input_text_508)
  else
    let prompt_510 = text_list_509[-1]
    let col_506 += (len(prompt_510))
    let text_list_509[-1] .= user_input_text_508
  endif
  for text_511 in text_list_509
    call setline(line_507,text_511)
    let line_507 += 1
  endfor
  let line_507 -= 1
  if !(empty(prompt_510))
    call ieie#set_prompt(a:ctx,line_507,prompt_510)
  endif
  call cursor(line_507,col_506)
  call winline()
  if bufnum_505 != a:ctx["bufnr"]
    return ieie#back_to_marked_window("switch476")
  endif
endfunction

function! ieie#get_prompt(ctx,line)
  if has_key(a:ctx,"prompt-history")
    return get(a:ctx["prompt-history"],a:line,"")
  else
    return ""
  endif
endfunction

function! ieie#set_prompt(ctx,line,text)
  if has_key(a:ctx,"prompt-history")
    let a:ctx["prompt-history"][a:line] = a:text
  else
    return ""
  endif
endfunction

let s:context_list = {}

let s:updatetime_save = &updatetime

let s:prev_check_output_time = 0

augroup ieie-plugin
  autocmd CursorHold * call s:cursor_hold("n")
  autocmd CursorHoldI * call s:cursor_hold("i")
  autocmd CursorMoved * call s:cursor_moved(0)
  autocmd CursorMovedI * call s:cursor_moved(0)
augroup END

function! ieie#get_context(bufnr)
  return get(s:context_list,a:bufnr,0)
endfunction

function! s:initialize_buffer(conf)
  let cap_512 = "[" . (s:get_caption(a:conf))
  let c_513 = ieie#count_window("let",s:get_mark(a:conf))
  edit `=(((c_513)?"-" . (c_513 + 1) : cap_512)) . "]"`
  setlocal buftype=nofile noswapfile
  setlocal bufhidden=delete
  setlocal nonumber
let &l:filetype=(s:get_filetype(a:conf))
let &l:syntax=(s:get_syntax(a:conf))
  execute "let b:" . (s:get_mark(a:conf)) . " = 1"
  augroup ieie-plugin
    autocmd! * <buffer>
    autocmd BufUnload <buffer> call s:unload_buffer()
    autocmd BufEnter <buffer> call s:buffer_enter()
    autocmd BufLeave <buffer> call s:buffer_leave()
  augroup END
endfunction

function! s:initialize_context(bufnum,ctx)
  let a:ctx["bufnr"] = a:bufnum
  let a:ctx["input-history-index"] = 0
  let a:ctx["is-buf-closed"] = 0
  let s:context_list[a:bufnum] = a:ctx
endfunction

function! s:create_buffer(conf)
  let ctx_514 = s:create_context(a:conf)
  silent! execute s:get_buffer_open_cmd(a:conf)
  enew
  call s:initialize_buffer(a:conf)
  call ieie_mapping#initialize()
  let bufnum_515 = bufnr("%")
  call s:initialize_context(bufnum_515,ctx_514)
  call s:buffer_enter()
  return ieie#check_output(ctx_514,250)
endfunction

function! ieie#open_interactive(conf)
  if get(a:conf,"always-new",0)
    call s:create_buffer(a:conf)
  elseif ieie#move_to_window("let",s:get_mark(a:conf))
    call cursor(line("$"),col("$"))
  else
    call s:create_buffer(a:conf)
  endif
  startinsert!
endfunction

function! s:finalize_interactive(ctx)
  if !a:ctx["is-buf-closed"]
    execute a:ctx["bufnr"] "wincmd q"
  endif
  unlet s:context_list[a:ctx["bufnr"]]
endfunction

function! s:unload_buffer()
  let ctx_516 = get(s:context_list,bufnr("%"),0)
  if ctx_516 isnot 0
    let ctx_516["is-buf-closed"] = 1
    return s:destry_context(ctx_516)
  endif
endfunction

function! s:cursor_hold(mode)
  call s:cursor_moved(0)
  if a:mode ==# "n"
    return feedkeys("g\<ESC>","n")
  elseif a:mode ==# "i"
    return feedkeys("a\<BS>","n")
  endif
endfunction

function! s:cursor_moved(timeout)
  if (0 != (len(s:context_list))) && (1 < ((localtime()) - s:prev_check_output_time))
    for ctx_517 in values(s:context_list)
      call ieie#check_output(ctx_517,a:timeout)
    endfor
    let s:prev_check_output_time = localtime()
  endif
endfunction

function! s:buffer_enter()
  call s:save_updatetime()
  let ctx_518 = get(s:context_list,bufnr("%"),0)
  if ctx_518 isnot 0
    let Enter_519 = ctx_518["buffer-enter"]
    if Enter_519 isnot 0
      return (type(Enter_519)==s:dict_type_482) ? Enter_519.func(ctx_518) : Enter_519(ctx_518)
    endif
  endif
endfunction

function! s:buffer_leave()
  call s:restore_updatetime()
  let ctx_520 = get(s:context_list,bufnr("%"),0)
  if ctx_520 isnot 0
    let Leave_521 = ctx_520["buffer-leave"]
    if Leave_521 isnot 0
      return (type(Leave_521)==s:dict_type_482) ? Leave_521.func(ctx_520) : Leave_521(ctx_520)
    endif
  endif
endfunction

function! s:save_updatetime()
  let s:updatetime_save = &updatetime
  if &updatetime > g:gosh_updatetime
    let &updatetime = g:gosh_updatetime
  endif
endfunction

function! s:restore_updatetime()
  if &updatetime < s:updatetime_save
    let &updatetime = s:updatetime_save
  endif
endfunction

function! s:discard_line(ctx)
  if a:ctx["proc"]["is_valid"] && a:ctx["proc"]["stdout"]["is_valid"] && (!a:ctx["proc"]["stdout"]["eof"])
    let out_522 = (type(a:ctx["proc"]["stdout"]["read"])==s:dict_type_482) ? a:ctx["proc"]["stdout"]["read"].func(-1,250) : a:ctx["proc"]["stdout"]["read"](-1,250)
    let newline_523 = s:get_newline_mark(out_522)
    let lines_524 = split(out_522,newline_523,1)
    let a:ctx["stdout-remain"] .= (join(lines_524[1:],newline_523))
  endif
endfunction

function! ieie#execute(text,bufnum,is_insert)
  let ctx_525 = ieie#get_context(a:bufnum)
  let bufnum_526 = bufnr("%")
  if bufnum_526 != (bufnr("%"))
    let l:changebuf = 1
    call ieie#mark_back_to_window("switch477")
    call ieie#move_to_buffer(bufnr("%"))
  endif
  call ieie#execute_text(ctx_525,a:text)
  execute ":$ normal o"
  let l_527 = line(".")
  call setline(l_527,(repeat(" ",lispindent(l_527))) . (getline(l_527)))
  let ctx_525["input-history-index"] = 0
  if bufnum_526 != (bufnr("%"))
    call ieie#back_to_marked_window("switch477")
  endif
  if a:is_insert && (!(exists("changebuf")))
    startinsert!
  endif
  if ctx_525["pty"]
    call s:discard_line(ctx_525)
  endif
  return ieie#check_output(ctx_525,100)
endfunction

function! s:block_split(text_block)
  return map(copy(split(a:text_block,"\n")),'substitute(v:val,"^[\t ]*","","")')
endfunction

function! s:get_visual_block()
  let tmp_528 = @@
  silent normal gvy
  let temp478_529 = @@
  let @@ = tmp_528
  return temp478_529
endfunction

function! ieie#send_text_block(opener,mark)range
  let v_530 = visualmode()
  let selected_531 = s:get_visual_block()
  let text_532 = ""
  let bufnum_533 = bufnr("%")
  if ("" isnot (getbufvar(bufnum_533,a:mark))) && (v_530 ==# "v") && (v_530 ==# "V")
    let ctx_534 = ieie#get_context(bufnum_533)
    let line_535 = a:firstline
    for line_text_536 in s:block_split(selected_531)
      let prompt_537 = ieie#get_prompt(ctx_534,line_535)
      if line_text_536 =~# "^" . prompt_537
        let line_text_536 = line_text_536[len(prompt_537):]
      endif
      let text_532 .= "\n" . line_text_536
      let line_535 += 1
    endfor
  else
    let text_532 = join(s:block_split(selected_531),"\n")
  endif
  return ieie#send_text(a:opener,a:mark,text_532)
endfunction

function! ieie#send_text(Opener,mark,text)
  let mode_538 = mode()
  let bufnum_539 = bufnr("%")
  if "" is (getbufvar(bufnum_539,a:mark))
    call ieie#mark_back_to_window("_send_text")
    if (type(a:Opener)==s:dict_type_482)
      call a:Opener.func()
    else
      call a:Opener()
    endif
  endif
  let bufnum_540 = bufnr("%")
  if !(ieie#execute(a:text,bufnum_540,0))
    call ieie#check_output(ieie#get_context(bufnum_540),1000)
  endif
  if "" is (getbufvar(bufnum_539,a:mark))
    call ieie#back_to_marked_window("_send_text")
  endif
  if mode_538 ==# "n"
    stopinsert
  endif
endfunction

function! ieie#count_window(kind,val)
  let c_541 = 0
  for i_542 in range(0,winnr("$"))
    let n_543 = winbufnr(i_542)
    if a:kind ==# "filetype"
      if (getbufvar(n_543,"&filetype")) ==# a:val
        let c_541 += 1
      endif
    elseif a:kind ==# "let"
      if getbufvar(n_543,a:val)
        let c_541 += 1
      endif
    endif
  endfor
  return c_541
endfunction

function! ieie#move_to_buffer(bufnum)
  for i_544 in range(0,winnr("$"))
    let n_545 = winbufnr(i_544)
    if a:bufnum == n_545
      if i_544 != 0
        execute i_544 "wincmd w"
      endif
      return n_545
    endif
  endfor
  return 0
endfunction

function! ieie#move_to_window(kind,val)
  for i_546 in range(0,winnr("$"))
    let n_547 = winbufnr(i_546)
    if ((a:kind ==# "filetype")?((getbufvar(n_547,"&filetype")) ==# a:val) : (((a:kind ==# "let")?(getbufvar(n_547,a:val)) : (0))))
      if i_546 != 0
        execute i_546 "wincmd w"
      endif
      return n_547
    endif
  endfor
  return 0
endfunction

function! ieie#find_buffer(kind,val)
  for i_548 in range(0,winnr("$"))
    let n_549 = winbufnr(i_548)
    if ((a:kind ==# "filetype")?((getbufvar(n_549,"&filetype")) ==# a:val) : (((a:kind ==# "let")?(getbufvar(n_549,a:val)) : (0))))
      return n_549
    endif
  endfor
  return 0
endfunction

function! ieie#mark_back_to_window(...)
  execute "let w:" . (get(a:000,0,"_ref_back")) . " = 1"
endfunction

function! ieie#unmark_back_to_window()
  unlet! w:_ref_back
endfunction

function! ieie#back_to_marked_window(...)
  let mark_550 = get(a:000,0,"_ref_back")
  for t_551 in range(1,tabpagenr("$"))
    for w_552 in range(1,winnr("$"))
      if gettabwinvar(t_551,w_552,mark_550)
        execute "tabnext" t_551
        execute w_552 "wincmd w"
        execute "unlet! w:" . mark_550
      endif
    endfor
  endfor
endfunction

