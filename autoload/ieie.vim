" Generated automatically DO NOT EDIT

function! s:SID_PREFIX_495()
  return matchstr(expand('<sfile>'),'<SNR>\d\+_\zeSID_PREFIX_495$')
endfunction

let s:dict_type_493 = type({})

let s:str_type = type("")

function! s:get_proc(conf)
  let Proc_492 = get(a:conf,"proc",0)
  if Proc_492 isnot 0
    if (type(Proc_492)) == s:str_type
      if has_key(a:conf,"stderr-printer")
        if get(a:conf,"pty",0)
          return vimproc#ptyopen(Proc_492,3)
        else
          return vimproc#popen3(Proc_492)
        endif
      elseif get(a:conf,"pty",0)
        return vimproc#ptyopen(Proc_492,2)
      else
        return vimproc#popen2(Proc_492)
      endif
    else
      return (type(Proc_492)==s:dict_type_493) ? Proc_492.func() : Proc_492()
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
  let Cmd_494 = get(a:conf,"buffer-open","15:sp")
  if (type(Cmd_494)) == s:str_type
    return Cmd_494
  else
    return (type(Cmd_494)==s:dict_type_493) ? Cmd_494.func(a:conf) : Cmd_494(a:conf)
  endif
endfunction

function! s:create_context(conf)
  return {'proc' : s:get_proc(a:conf),'pty' : get(a:conf,"pty",0),'stdout-printer' : get(a:conf,"stdout-printer",function(s:SID_PREFIX_495() . 'default_printer')),'stderr-printer' : ((has_key(a:conf,"stderr-printer"))?(((a:conf["stderr-printer"] isnot 0)?a:conf["stderr-printer"] : function(s:SID_PREFIX_495() . 'default_printer'))) : 0),'exit-callback' : get(a:conf,"exit-callback",0),'buffer-enter' : get(a:conf,"buffer-enter",0),'buffer-leave' : get(a:conf,"buffer-leave",0),'lines' : [],'prompt-history' : {},'stdout-remain' : "",'stderr-reamin' : "",'stdout-reader' : ((has_key(a:conf,"stdout-read-line?"))?(((a:conf["stdout-read-line?"])?function(s:SID_PREFIX_495() . 'read_output_lines') : function(s:SID_PREFIX_495() . 'read_output'))) : function(s:SID_PREFIX_495() . 'read_output')),'stderr-reader' : ((has_key(a:conf,"stderr-read-line?"))?(((a:conf["stderr-read-line?"])?function(s:SID_PREFIX_495() . 'read_output_lines') : function(s:SID_PREFIX_495() . 'read_output'))) : function(s:SID_PREFIX_495() . 'read_output'))}
endfunction

function! s:destry_context(ctx)
  if (type(a:ctx["proc"]["stdin"]["close"])==s:dict_type_493)
    call a:ctx["proc"]["stdin"]["close"].func()
  else
    call a:ctx["proc"]["stdin"]["close"]()
  endif
  if (type(a:ctx["proc"]["stdout"]["close"])==s:dict_type_493)
    call a:ctx["proc"]["stdout"]["close"].func()
  else
    call a:ctx["proc"]["stdout"]["close"]()
  endif
  return s:run_exit_callback(a:ctx)
endfunction

function! s:run_exit_callback(ctx)
  call s:buffer_leave()
  let Exit_496 = a:ctx["exit-callback"]
  if Exit_496 isnot 0
    if (type(Exit_496)==s:dict_type_493)
      call Exit_496.func(a:ctx)
    else
      call Exit_496(a:ctx)
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
    return (type(a:ctx["proc"]["stdin"]["write"])==s:dict_type_493) ? a:ctx["proc"]["stdin"]["write"].func(((a:text !~# "\n$")?a:text . "\n" : a:text)) : a:ctx["proc"]["stdin"]["write"](((a:text !~# "\n$")?a:text . "\n" : a:text))
  endif
endfunction

function! ieie#check_output(ctx,...)
  if (!a:ctx["proc"]["is_valid"]) || (!a:ctx["proc"]["stdout"]["is_valid"]) || a:ctx["proc"]["stdout"]["eof"]
    return s:run_exit_callback(a:ctx)
  else
    let outputP_497 = 0
    let Printer_498 = a:ctx["stderr-printer"]
    if Printer_498 isnot 0
      let [out_499,remain_500] = (type(a:ctx["stderr-reader"])==s:dict_type_493) ? a:ctx["stderr-reader"].func(a:ctx["proc"]["stderr"],get(a:000,0,0),a:ctx["stderr-remain"]) : a:ctx["stderr-reader"](a:ctx["proc"]["stderr"],get(a:000,0,0),a:ctx["stderr-remain"])
      let a:ctx["stderr-remain"] = remain_500
      if !(empty(out_499))
        if (type(Printer_498)==s:dict_type_493)
          call Printer_498.func(a:ctx,out_499)
        else
          call Printer_498(a:ctx,out_499)
        endif
      endif
    endif
    let Printer_501 = a:ctx["stdout-printer"]
    if Printer_501 isnot 0
      let [out_502,remain_503] = (type(a:ctx["stdout-reader"])==s:dict_type_493) ? a:ctx["stdout-reader"].func(a:ctx["proc"]["stdout"],get(a:000,0,0),a:ctx["stdout-remain"]) : a:ctx["stdout-reader"](a:ctx["proc"]["stdout"],get(a:000,0,0),a:ctx["stdout-remain"])
      let a:ctx["stdout-remain"] = remain_503
      if !(empty(out_502))
        let outputP_497 = 1
        if (type(Printer_501)==s:dict_type_493)
          call Printer_501.func(a:ctx,out_502)
        else
          call Printer_501(a:ctx,out_502)
        endif
      endif
    endif
    return outputP_497
  endif
endfunction

function! s:read_output(port,timeout,remain)
  let out_504 = ""
  let res_505 = a:remain . ((type(a:port["read"])==s:dict_type_493) ? a:port["read"].func(-1,a:timeout) : a:port["read"](-1,a:timeout))
  let recursion_506 = 1
  while recursion_506
    let recursion_506 = 0
    if empty(res_505)
      return [out_504,""]
    else
      let recursion_506 = 1
      let out_504 = out_504 . res_505
      let res_505 = (type(a:port["read"])==s:dict_type_493) ? a:port["read"].func(-1,15) : a:port["read"](-1,15)
    endif
  endwhile
endfunction

function! s:read_output_lines(port,timeout,remain)
  let out_507 = ""
  let res_508 = a:remain . ((type(a:port["read"])==s:dict_type_493) ? a:port["read"].func(-1,a:timeout) : a:port["read"](-1,a:timeout))
  let recursion_509 = 1
  while recursion_509
    let recursion_509 = 0
    if empty(res_508)
      let index_510 = strridx(out_507,"\n")
      if index_510 < 0
        return ["",out_507]
      elseif index_510 != 0
        return [out_507[0:index_510 - 1],out_507[index_510 + 1:]]
      else
        return ["",out_507[index_510 + 1:]]
      endif
    else
      let recursion_509 = 1
      let out_507 = out_507 . res_508
      let res_508 = (type(a:port["read"])==s:dict_type_493) ? a:port["read"].func(512,100) : a:port["read"](512,100)
    endif
  endwhile
endfunction

function! s:get_newline_mark(text)
  let idx_511 = stridx(a:text,"\r")
  if -1 == idx_511
    return "\n"
  elseif a:text[idx_511 + 1] == "\n"
    return "\r\n"
  else
    return "\r"
  endif
endfunction

function! s:line_split(text)
  return split(a:text,s:get_newline_mark(a:text))
endfunction

function! s:get_user_input_text_26output_text_list(ctx,line,text)
  let prompt_512 = ieie#get_prompt(a:ctx,a:line)
  let line_text_513 = getline(a:line)
  let user_input_text_514 = line_text_513[(stridx(line_text_513,prompt_512)) + (len(prompt_512)):]
  let text_list_515 = s:line_split(a:text)
  if !(empty(prompt_512))
    if 0 == (len(text_list_515))
      call add(text_list_515,prompt_512)
    else
      let text_list_515[0] = prompt_512 . text_list_515[0]
    endif
  endif
  return [user_input_text_514,text_list_515]
endfunction

function! s:default_printer(ctx,text)
  if empty(a:text)
    return
  endif
  let bufnum_516 = bufnr("%")
  if bufnum_516 != a:ctx["bufnr"]
    let l:changebuf = 1
    call ieie#mark_back_to_window("switch487")
    call ieie#move_to_buffer(a:ctx["bufnr"])
  endif
  let col_517 = col(".")
  let line_518 = line(".")
  let [user_input_text_519,text_list_520] = s:get_user_input_text_26output_text_list(a:ctx,line_518,a:text)
  let prompt_521 = ""
  if a:text[-1] ==# "\n"
    call add(text_list_520,user_input_text_519)
  else
    let prompt_521 = text_list_520[-1]
    let col_517 += (len(prompt_521))
    let text_list_520[-1] .= user_input_text_519
  endif
  for text_522 in text_list_520
    call setline(line_518,text_522)
    let line_518 += 1
  endfor
  let line_518 -= 1
  if !(empty(prompt_521))
    call ieie#set_prompt(a:ctx,line_518,prompt_521)
  endif
  call cursor(line_518,col_517)
  call winline()
  if bufnum_516 != a:ctx["bufnr"]
    return ieie#back_to_marked_window("switch487")
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

function! ieie#get_context(bufnr)
  return get(s:context_list,a:bufnr,0)
endfunction

function! s:initialize_buffer(conf)
  let cap_523 = "[" . (s:get_caption(a:conf))
  let c_524 = ieie#count_window("let",s:get_mark(a:conf))
  edit `=(((c_524)?"-" . (c_524 + 1) : cap_523)) . "]"`
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
    autocmd CursorHold <buffer> call s:cursor_hold("n")
    autocmd CursorHoldI <buffer> call s:cursor_hold("i")
    autocmd CursorMoved <buffer> call s:cursor_moved(0)
    autocmd CursorMovedI <buffer> call s:cursor_moved(0)
  augroup END
endfunction

function! s:initialize_context(bufnum,ctx)
  let a:ctx["bufnr"] = a:bufnum
  let a:ctx["input-history-index"] = 0
  let a:ctx["is-buf-closed"] = 0
  let s:context_list[a:bufnum] = a:ctx
endfunction

function! s:create_buffer(conf)
  let ctx_525 = s:create_context(a:conf)
  silent! execute s:get_buffer_open_cmd(a:conf)
  enew
  call s:initialize_buffer(a:conf)
  call ieie_mapping#initialize()
  let bufnum_526 = bufnr("%")
  call s:initialize_context(bufnum_526,ctx_525)
  call s:buffer_enter()
  return ieie#check_output(ctx_525,250)
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
  let ctx_527 = get(s:context_list,bufnr("%"),0)
  if ctx_527 isnot 0
    let ctx_527["is-buf-closed"] = 1
    return s:destry_context(ctx_527)
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
  for ctx_528 in values(s:context_list)
    call ieie#check_output(ctx_528,a:timeout)
  endfor
endfunction

function! s:buffer_enter()
  call s:save_updatetime()
  let ctx_529 = get(s:context_list,bufnr("%"),0)
  if ctx_529 isnot 0
    let Enter_530 = ctx_529["buffer-enter"]
    if Enter_530 isnot 0
      return (type(Enter_530)==s:dict_type_493) ? Enter_530.func(ctx_529) : Enter_530(ctx_529)
    endif
  endif
endfunction

function! s:buffer_leave()
  call s:restore_updatetime()
  let ctx_531 = get(s:context_list,bufnr("%"),0)
  if ctx_531 isnot 0
    let Leave_532 = ctx_531["buffer-leave"]
    if Leave_532 isnot 0
      return (type(Leave_532)==s:dict_type_493) ? Leave_532.func(ctx_531) : Leave_532(ctx_531)
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
    let out_533 = (type(a:ctx["proc"]["stdout"]["read"])==s:dict_type_493) ? a:ctx["proc"]["stdout"]["read"].func(-1,250) : a:ctx["proc"]["stdout"]["read"](-1,250)
    let newline_534 = s:get_newline_mark(out_533)
    let lines_535 = split(out_533,newline_534,1)
    let a:ctx["stdout-remain"] .= (join(lines_535[1:],newline_534))
  endif
endfunction

function! ieie#execute(text,bufnum,is_insert)
  let ctx_536 = ieie#get_context(a:bufnum)
  let bufnum_537 = bufnr("%")
  if bufnum_537 != (bufnr("%"))
    let l:changebuf = 1
    call ieie#mark_back_to_window("switch488")
    call ieie#move_to_buffer(bufnr("%"))
  endif
  call ieie#execute_text(ctx_536,a:text)
  execute ":$ normal o"
  let l_538 = line(".")
  call setline(l_538,(repeat(" ",lispindent(l_538))) . (getline(l_538)))
  let ctx_536["input-history-index"] = 0
  if bufnum_537 != (bufnr("%"))
    call ieie#back_to_marked_window("switch488")
  endif
  if a:is_insert && (!(exists("changebuf")))
    startinsert!
  endif
  if ctx_536["pty"]
    call s:discard_line(ctx_536)
  endif
  return ieie#check_output(ctx_536,100)
endfunction

function! s:block_split(text_block)
  return map(copy(split(a:text_block,"\n")),'substitute(v:val,"^[\t ]*","","")')
endfunction

function! s:get_visual_block()
  let tmp_539 = @@
  silent normal gvy
  let temp489_540 = @@
  let @@ = tmp_539
  return temp489_540
endfunction

function! ieie#send_text_block(opener,mark)range
  let v_541 = visualmode()
  let selected_542 = s:get_visual_block()
  let text_543 = ""
  let bufnum_544 = bufnr("%")
  if ("" isnot (getbufvar(bufnum_544,a:mark))) && (v_541 ==# "v") && (v_541 ==# "V")
    let ctx_545 = ieie#get_context(bufnum_544)
    let line_546 = a:firstline
    for line_text_547 in s:block_split(selected_542)
      let prompt_548 = ieie#get_prompt(ctx_545,line_546)
      if line_text_547 =~# "^" . prompt_548
        let line_text_547 = line_text_547[len(prompt_548):]
      endif
      let text_543 .= "\n" . line_text_547
      let line_546 += 1
    endfor
  else
    let text_543 = join(s:block_split(selected_542),"\n")
  endif
  return ieie#send_text(a:opener,a:mark,text_543)
endfunction

function! ieie#send_text(Opener,mark,text)
  let mode_549 = mode()
  let bufnum_550 = bufnr("%")
  if "" is (getbufvar(bufnum_550,a:mark))
    call ieie#mark_back_to_window("_send_text")
    if (type(a:Opener)==s:dict_type_493)
      call a:Opener.func()
    else
      call a:Opener()
    endif
  endif
  let bufnum_551 = bufnr("%")
  if !(ieie#execute(a:text,bufnum_551,0))
    call ieie#check_output(ieie#get_context(bufnum_551),1000)
  endif
  if "" is (getbufvar(bufnum_550,a:mark))
    call ieie#back_to_marked_window("_send_text")
  endif
  if mode_549 ==# "n"
    stopinsert
  endif
endfunction

function! ieie#count_window(kind,val)
  let c_552 = 0
  for i_553 in range(0,winnr("$"))
    let n_554 = winbufnr(i_553)
    if a:kind ==# "filetype"
      if (getbufvar(n_554,"&filetype")) ==# a:val
        let c_552 += 1
      endif
    elseif a:kind ==# "let"
      if getbufvar(n_554,a:val)
        let c_552 += 1
      endif
    endif
  endfor
  return c_552
endfunction

function! ieie#move_to_buffer(bufnum)
  for i_555 in range(0,winnr("$"))
    let n_556 = winbufnr(i_555)
    if a:bufnum == n_556
      if i_555 != 0
        execute i_555 "wincmd w"
      endif
      return n_556
    endif
  endfor
  return 0
endfunction

function! ieie#move_to_window(kind,val)
  for i_557 in range(0,winnr("$"))
    let n_558 = winbufnr(i_557)
    if ((a:kind ==# "filetype")?((getbufvar(n_558,"&filetype")) ==# a:val) : (((a:kind ==# "let")?(getbufvar(n_558,a:val)) : (0))))
      if i_557 != 0
        execute i_557 "wincmd w"
      endif
      return n_558
    endif
  endfor
  return 0
endfunction

function! ieie#find_buffer(kind,val)
  for i_559 in range(0,winnr("$"))
    let n_560 = winbufnr(i_559)
    if ((a:kind ==# "filetype")?((getbufvar(n_560,"&filetype")) ==# a:val) : (((a:kind ==# "let")?(getbufvar(n_560,a:val)) : (0))))
      return n_560
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
  let mark_561 = get(a:000,0,"_ref_back")
  for t_562 in range(1,tabpagenr("$"))
    for w_563 in range(1,winnr("$"))
      if gettabwinvar(t_562,w_563,mark_561)
        execute "tabnext" t_562
        execute w_563 "wincmd w"
        execute "unlet! w:" . mark_561
      endif
    endfor
  endfor
endfunction

