" Generated automatically DO NOT EDIT

function! s:SID_PREFIX_485()
  return matchstr(expand('<sfile>'),'<SNR>\d\+_\zeSID_PREFIX_485$')
endfunction

let s:dict_type_483 = type({})

let s:str_type = type("")

function! s:get_proc(conf)
  let Proc_482 = get(a:conf,"proc",0)
  if Proc_482 isnot 0
    if (type(Proc_482)) == s:str_type
      if has_key(a:conf,"stderr-printer")
        if get(a:conf,"pty",0)
          return vimproc#ptyopen(Proc_482,3)
        else
          return vimproc#popen3(Proc_482)
        endif
      elseif get(a:conf,"pty",0)
        return vimproc#ptyopen(Proc_482,2)
      else
        return vimproc#popen2(Proc_482)
      endif
    else
      return (type(Proc_482)==s:dict_type_483) ? Proc_482.func() : Proc_482()
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
  let Cmd_484 = get(a:conf,"buffer-open","15:sp")
  if (type(Cmd_484)) == s:str_type
    return Cmd_484
  else
    return (type(Cmd_484)==s:dict_type_483) ? Cmd_484.func(a:conf) : Cmd_484(a:conf)
  endif
endfunction

function! s:create_context(conf)
  return {'proc' : s:get_proc(a:conf),'pty' : get(a:conf,"pty",0),'stdout-printer' : get(a:conf,"stdout-printer",function(s:SID_PREFIX_485() . 'default_printer')),'stderr-printer' : ((has_key(a:conf,"stderr-printer"))?(((a:conf["stderr-printer"] isnot 0)?a:conf["stderr-printer"] : function(s:SID_PREFIX_485() . 'default_printer'))) : 0),'exit-callback' : get(a:conf,"exit-callback",0),'buffer-enter' : get(a:conf,"buffer-enter",0),'buffer-leave' : get(a:conf,"buffer-leave",0),'lines' : [],'prompt-history' : {},'stdout-remain' : "",'stderr-reamin' : "",'stdout-reader' : ((has_key(a:conf,"stdout-read-line?"))?(((a:conf["stdout-read-line?"])?function(s:SID_PREFIX_485() . 'read_output_lines') : function(s:SID_PREFIX_485() . 'read_output'))) : function(s:SID_PREFIX_485() . 'read_output')),'stderr-reader' : ((has_key(a:conf,"stderr-read-line?"))?(((a:conf["stderr-read-line?"])?function(s:SID_PREFIX_485() . 'read_output_lines') : function(s:SID_PREFIX_485() . 'read_output'))) : function(s:SID_PREFIX_485() . 'read_output'))}
endfunction

function! s:destry_context(ctx)
  if (type(a:ctx["proc"]["stdin"]["close"])==s:dict_type_483)
    call a:ctx["proc"]["stdin"]["close"].func()
  else
    call a:ctx["proc"]["stdin"]["close"]()
  endif
  if (type(a:ctx["proc"]["stdout"]["close"])==s:dict_type_483)
    call a:ctx["proc"]["stdout"]["close"].func()
  else
    call a:ctx["proc"]["stdout"]["close"]()
  endif
  return s:run_exit_callback(a:ctx)
endfunction

function! s:run_exit_callback(ctx)
  call s:buffer_leave()
  let Exit_486 = a:ctx["exit-callback"]
  if Exit_486 isnot 0
    if (type(Exit_486)==s:dict_type_483)
      call Exit_486.func(a:ctx)
    else
      call Exit_486(a:ctx)
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
    return (type(a:ctx["proc"]["stdin"]["write"])==s:dict_type_483) ? a:ctx["proc"]["stdin"]["write"].func(((a:text !~# "\n$")?a:text . "\n" : a:text)) : a:ctx["proc"]["stdin"]["write"](((a:text !~# "\n$")?a:text . "\n" : a:text))
  endif
endfunction

function! ieie#check_output(ctx,...)
  if (!a:ctx["proc"]["is_valid"]) || (!a:ctx["proc"]["stdout"]["is_valid"]) || a:ctx["proc"]["stdout"]["eof"]
    return s:run_exit_callback(a:ctx)
  else
    let outputP_487 = 0
    let Printer_488 = a:ctx["stderr-printer"]
    if Printer_488 isnot 0
      let [out_489,remain_490] = (type(a:ctx["stderr-reader"])==s:dict_type_483) ? a:ctx["stderr-reader"].func(a:ctx["proc"]["stderr"],get(a:000,0,0),a:ctx["stderr-remain"]) : a:ctx["stderr-reader"](a:ctx["proc"]["stderr"],get(a:000,0,0),a:ctx["stderr-remain"])
      let a:ctx["stderr-remain"] = remain_490
      if !(empty(out_489))
        if (type(Printer_488)==s:dict_type_483)
          call Printer_488.func(a:ctx,out_489)
        else
          call Printer_488(a:ctx,out_489)
        endif
      endif
    endif
    let Printer_491 = a:ctx["stdout-printer"]
    if Printer_491 isnot 0
      let [out_492,remain_493] = (type(a:ctx["stdout-reader"])==s:dict_type_483) ? a:ctx["stdout-reader"].func(a:ctx["proc"]["stdout"],get(a:000,0,0),a:ctx["stdout-remain"]) : a:ctx["stdout-reader"](a:ctx["proc"]["stdout"],get(a:000,0,0),a:ctx["stdout-remain"])
      let a:ctx["stdout-remain"] = remain_493
      if !(empty(out_492))
        let outputP_487 = 1
        if (type(Printer_491)==s:dict_type_483)
          call Printer_491.func(a:ctx,out_492)
        else
          call Printer_491(a:ctx,out_492)
        endif
      endif
    endif
    return outputP_487
  endif
endfunction

function! s:read_output(port,timeout,remain)
  let out_494 = ""
  let res_495 = a:remain . ((type(a:port["read"])==s:dict_type_483) ? a:port["read"].func(-1,a:timeout) : a:port["read"](-1,a:timeout))
  let recursion_496 = 1
  while recursion_496
    let recursion_496 = 0
    if empty(res_495)
      return [out_494,""]
    else
      let recursion_496 = 1
      let out_494 = out_494 . res_495
      let res_495 = (type(a:port["read"])==s:dict_type_483) ? a:port["read"].func(-1,15) : a:port["read"](-1,15)
    endif
  endwhile
endfunction

function! s:read_output_lines(port,timeout,remain)
  let out_497 = ""
  let res_498 = a:remain . ((type(a:port["read"])==s:dict_type_483) ? a:port["read"].func(-1,a:timeout) : a:port["read"](-1,a:timeout))
  let recursion_499 = 1
  while recursion_499
    let recursion_499 = 0
    if empty(res_498)
      let index_500 = strridx(out_497,"\n")
      if index_500 < 0
        return ["",out_497]
      elseif index_500 != 0
        return [out_497[0:index_500 - 1],out_497[index_500 + 1:]]
      else
        return ["",out_497[index_500 + 1:]]
      endif
    else
      let recursion_499 = 1
      let out_497 = out_497 . res_498
      let res_498 = (type(a:port["read"])==s:dict_type_483) ? a:port["read"].func(512,100) : a:port["read"](512,100)
    endif
  endwhile
endfunction

function! s:get_newline_mark(text)
  let idx_501 = stridx(a:text,"\r")
  if -1 == idx_501
    return "\n"
  elseif a:text[idx_501 + 1] == "\n"
    return "\r\n"
  else
    return "\r"
  endif
endfunction

function! s:line_split(text)
  return split(a:text,s:get_newline_mark(a:text))
endfunction

function! s:get_user_input_text_26output_text_list(ctx,line,text)
  let prompt_502 = ieie#get_prompt(a:ctx,a:line)
  let line_text_503 = getline(a:line)
  let user_input_text_504 = line_text_503[(stridx(line_text_503,prompt_502)) + (len(prompt_502)):]
  let text_list_505 = s:line_split(a:text)
  if !(empty(prompt_502))
    if 0 == (len(text_list_505))
      call add(text_list_505,prompt_502)
    else
      let text_list_505[0] = prompt_502 . text_list_505[0]
    endif
  endif
  return [user_input_text_504,text_list_505]
endfunction

function! s:default_printer(ctx,text)
  if empty(a:text)
    return
  endif
  let bufnum_506 = bufnr("%")
  if bufnum_506 != a:ctx["bufnr"]
    let l:changebuf = 1
    call ieie#mark_back_to_window("switch477")
    call ieie#move_to_buffer(a:ctx["bufnr"])
  endif
  let col_507 = col(".")
  let line_508 = line(".")
  let [user_input_text_509,text_list_510] = s:get_user_input_text_26output_text_list(a:ctx,line_508,a:text)
  let prompt_511 = ""
  if a:text[-1] ==# "\n"
    call add(text_list_510,user_input_text_509)
  else
    let prompt_511 = text_list_510[-1]
    let col_507 += (len(prompt_511))
    let text_list_510[-1] .= user_input_text_509
  endif
  for text_512 in text_list_510
    call setline(line_508,text_512)
    let line_508 += 1
  endfor
  let line_508 -= 1
  if !(empty(prompt_511))
    call ieie#set_prompt(a:ctx,line_508,prompt_511)
  endif
  call cursor(line_508,col_507)
  call winline()
  if bufnum_506 != a:ctx["bufnr"]
    return ieie#back_to_marked_window("switch477")
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
  let cap_513 = "[" . (s:get_caption(a:conf))
  let c_514 = ieie#count_window("let",s:get_mark(a:conf))
  edit `=(((c_514)?"-" . (c_514 + 1) : cap_513)) . "]"`
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
  let ctx_515 = s:create_context(a:conf)
  silent! execute s:get_buffer_open_cmd(a:conf)
  enew
  call s:initialize_buffer(a:conf)
  call ieie_mapping#initialize()
  let bufnum_516 = bufnr("%")
  call s:initialize_context(bufnum_516,ctx_515)
  call s:buffer_enter()
  return ieie#check_output(ctx_515,250)
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
  let ctx_517 = get(s:context_list,bufnr("%"),0)
  if ctx_517 isnot 0
    let ctx_517["is-buf-closed"] = 1
    return s:destry_context(ctx_517)
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
  for ctx_518 in values(s:context_list)
    call ieie#check_output(ctx_518,a:timeout)
  endfor
endfunction

function! s:buffer_enter()
  call s:save_updatetime()
  let ctx_519 = get(s:context_list,bufnr("%"),0)
  if ctx_519 isnot 0
    let Enter_520 = ctx_519["buffer-enter"]
    if Enter_520 isnot 0
      return (type(Enter_520)==s:dict_type_483) ? Enter_520.func(ctx_519) : Enter_520(ctx_519)
    endif
  endif
endfunction

function! s:buffer_leave()
  call s:restore_updatetime()
  let ctx_521 = get(s:context_list,bufnr("%"),0)
  if ctx_521 isnot 0
    let Leave_522 = ctx_521["buffer-leave"]
    if Leave_522 isnot 0
      return (type(Leave_522)==s:dict_type_483) ? Leave_522.func(ctx_521) : Leave_522(ctx_521)
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
    let out_523 = (type(a:ctx["proc"]["stdout"]["read"])==s:dict_type_483) ? a:ctx["proc"]["stdout"]["read"].func(-1,250) : a:ctx["proc"]["stdout"]["read"](-1,250)
    let newline_524 = s:get_newline_mark(out_523)
    let lines_525 = split(out_523,newline_524,1)
    let a:ctx["stdout-remain"] .= (join(lines_525[1:],newline_524))
  endif
endfunction

function! ieie#execute(text,bufnum,is_insert)
  let ctx_526 = ieie#get_context(a:bufnum)
  let bufnum_527 = bufnr("%")
  if bufnum_527 != (bufnr("%"))
    let l:changebuf = 1
    call ieie#mark_back_to_window("switch478")
    call ieie#move_to_buffer(bufnr("%"))
  endif
  call ieie#execute_text(ctx_526,a:text)
  execute ":$ normal o"
  let l_528 = line(".")
  call setline(l_528,(repeat(" ",lispindent(l_528))) . (getline(l_528)))
  let ctx_526["input-history-index"] = 0
  if bufnum_527 != (bufnr("%"))
    call ieie#back_to_marked_window("switch478")
  endif
  if a:is_insert && (!(exists("changebuf")))
    startinsert!
  endif
  if ctx_526["pty"]
    call s:discard_line(ctx_526)
  endif
  return ieie#check_output(ctx_526,100)
endfunction

function! s:block_split(text_block)
  return map(copy(split(a:text_block,"\n")),'substitute(v:val,"^[\t ]*","","")')
endfunction

function! s:get_visual_block()
  let tmp_529 = @@
  silent normal gvy
  let temp479_530 = @@
  let @@ = tmp_529
  return temp479_530
endfunction

function! ieie#send_text_block(opener,mark)range
  let v_531 = visualmode()
  let selected_532 = s:get_visual_block()
  let text_533 = ""
  let bufnum_534 = bufnr("%")
  if ("" isnot (getbufvar(bufnum_534,a:mark))) && (v_531 ==# "v") && (v_531 ==# "V")
    let ctx_535 = ieie#get_context(bufnum_534)
    let line_536 = a:firstline
    for line_text_537 in s:block_split(selected_532)
      let prompt_538 = ieie#get_prompt(ctx_535,line_536)
      if line_text_537 =~# "^" . prompt_538
        let line_text_537 = line_text_537[len(prompt_538):]
      endif
      let text_533 .= " " . line_text_537
      let line_536 += 1
    endfor
  else
    let text_533 = join(s:block_split(selected_532)," ")
  endif
  return ieie#send_text(a:opener,a:mark,text_533)
endfunction

function! ieie#send_text(Opener,mark,text)
  let mode_539 = mode()
  let bufnum_540 = bufnr("%")
  if "" is (getbufvar(bufnum_540,a:mark))
    call ieie#mark_back_to_window("_send_text")
    if (type(a:Opener)==s:dict_type_483)
      call a:Opener.func()
    else
      call a:Opener()
    endif
  endif
  let bufnum_541 = bufnr("%")
  if !(ieie#execute(a:text,bufnum_541,0))
    call ieie#check_output(ieie#get_context(bufnum_541),1000)
  endif
  if "" is (getbufvar(bufnum_540,a:mark))
    call ieie#back_to_marked_window("_send_text")
  endif
  if mode_539 ==# "n"
    stopinsert
  endif
endfunction

function! ieie#count_window(kind,val)
  let c_542 = 0
  for i_543 in range(0,winnr("$"))
    let n_544 = winbufnr(i_543)
    if a:kind ==# "filetype"
      if (getbufvar(n_544,"&filetype")) ==# a:val
        let c_542 += 1
      endif
    elseif a:kind ==# "let"
      if getbufvar(n_544,a:val)
        let c_542 += 1
      endif
    endif
  endfor
  return c_542
endfunction

function! ieie#move_to_buffer(bufnum)
  for i_545 in range(0,winnr("$"))
    let n_546 = winbufnr(i_545)
    if a:bufnum == n_546
      if i_545 != 0
        execute i_545 "wincmd w"
      endif
      return n_546
    endif
  endfor
  return 0
endfunction

function! ieie#move_to_window(kind,val)
  for i_547 in range(0,winnr("$"))
    let n_548 = winbufnr(i_547)
    if ((a:kind ==# "filetype")?((getbufvar(n_548,"&filetype")) ==# a:val) : (((a:kind ==# "let")?(getbufvar(n_548,a:val)) : (0))))
      if i_547 != 0
        execute i_547 "wincmd w"
      endif
      return n_548
    endif
  endfor
  return 0
endfunction

function! ieie#find_buffer(kind,val)
  for i_549 in range(0,winnr("$"))
    let n_550 = winbufnr(i_549)
    if ((a:kind ==# "filetype")?((getbufvar(n_550,"&filetype")) ==# a:val) : (((a:kind ==# "let")?(getbufvar(n_550,a:val)) : (0))))
      return n_550
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
  let mark_551 = get(a:000,0,"_ref_back")
  for t_552 in range(1,tabpagenr("$"))
    for w_553 in range(1,winnr("$"))
      if gettabwinvar(t_552,w_553,mark_551)
        execute "tabnext" t_552
        execute w_553 "wincmd w"
        execute "unlet! w:" . mark_551
      endif
    endfor
  endfor
endfunction

