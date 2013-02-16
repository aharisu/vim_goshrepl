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
        return vimproc#popen3(Proc_482)
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
  return {'proc' : s:get_proc(a:conf),'stdout-printer' : get(a:conf,"stdout-printer",function(s:SID_PREFIX_485() . 'default_printer')),'stderr-printer' : ((has_key(a:conf,"stderr-printer"))?(((a:conf["stderr-printer"] isnot 0)?a:conf["stderr-printer"] : function(s:SID_PREFIX_485() . 'default_printer'))) : 0),'exit-callback' : get(a:conf,"exit-callback",0),'buffer-enter' : get(a:conf,"buffer-enter",0),'buffer-leave' : get(a:conf,"buffer-leave",0),'lines' : [],'prompt-history' : {},'stdout-remain' : "",'stderr-reamin' : "",'stdout-reader' : ((has_key(a:conf,"stdout-read-line?"))?(((a:conf["stdout-read-line?"])?function(s:SID_PREFIX_485() . 'read_output_lines') : function(s:SID_PREFIX_485() . 'read_output'))) : function(s:SID_PREFIX_485() . 'read_output')),'stderr-reader' : ((has_key(a:conf,"stderr-read-line?"))?(((a:conf["stderr-read-line?"])?function(s:SID_PREFIX_485() . 'read_output_lines') : function(s:SID_PREFIX_485() . 'read_output'))) : function(s:SID_PREFIX_485() . 'read_output'))}
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
  let res_495 = (type(a:port["read"])==s:dict_type_483) ? a:port["read"].func(-1,a:timeout) : a:port["read"](-1,a:timeout)
  let recursion_496 = 1
  while recursion_496
    let recursion_496 = 0
    if empty(res_495)
      return [out_494,a:remain]
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

function! s:get_user_input_text_26output_text_list(ctx,line,text)
  let prompt_501 = ieie#get_prompt(a:ctx,a:line)
  let line_text_502 = getline(a:line)
  let user_input_text_503 = line_text_502[(stridx(line_text_502,prompt_501)) + (len(prompt_501)):]
  let text_list_504 = split(a:text,"\n")
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
    call ieie#mark_back_to_window("switch477")
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
  for ctx_517 in values(s:context_list)
    call ieie#check_output(ctx_517,a:timeout)
  endfor
endfunction

function! s:buffer_enter()
  call s:save_updatetime()
  let ctx_518 = get(s:context_list,bufnr("%"),0)
  if ctx_518 isnot 0
    let Enter_519 = ctx_518["buffer-enter"]
    if Enter_519 isnot 0
      return (type(Enter_519)==s:dict_type_483) ? Enter_519.func(ctx_518) : Enter_519(ctx_518)
    endif
  endif
endfunction

function! s:buffer_leave()
  call s:restore_updatetime()
  let ctx_520 = get(s:context_list,bufnr("%"),0)
  if ctx_520 isnot 0
    let Leave_521 = ctx_520["buffer-leave"]
    if Leave_521 isnot 0
      return (type(Leave_521)==s:dict_type_483) ? Leave_521.func(ctx_520) : Leave_521(ctx_520)
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

function! ieie#execute(text,bufnum,is_insert)
  let ctx_522 = ieie#get_context(a:bufnum)
  let bufnum_523 = bufnr("%")
  if bufnum_523 != (bufnr("%"))
    let l:changebuf = 1
    call ieie#mark_back_to_window("switch478")
    call ieie#move_to_buffer(bufnr("%"))
  endif
  call ieie#execute_text(ctx_522,a:text)
  execute ":$ normal o"
  let l_524 = line(".")
  call setline(l_524,(repeat(" ",lispindent(l_524))) . (getline(l_524)))
  let ctx_522["input-history-index"] = 0
  if bufnum_523 != (bufnr("%"))
    call ieie#back_to_marked_window("switch478")
  endif
  if a:is_insert && (!(exists("changebuf")))
    startinsert!
  endif
  return ieie#check_output(ctx_522,100)
endfunction

function! s:line_split(text_block)
  return map(copy(split(a:text_block,"\n")),'substitute(v:val,"^[\t ]*","","")')
endfunction

function! s:get_visual_block()
  let tmp_525 = @@
  silent normal gvy
  let temp479_526 = @@
  let @@ = tmp_525
  return temp479_526
endfunction

function! ieie#send_text_block(opener,mark)range
  let v_527 = visualmode()
  let selected_528 = s:get_visual_block()
  let text_529 = ""
  let bufnum_530 = bufnr("%")
  if ("" isnot (getbufvar(bufnum_530,a:mark))) && (v_527 ==# "v") && (v_527 ==# "V")
    let ctx_531 = ieie#get_context(bufnum_530)
    let line_532 = a:firstline
    for line_text_533 in s:line_split(selected_528)
      let prompt_534 = ieie#get_prompt(ctx_531,line_532)
      if line_text_533 =~# "^" . prompt_534
        let line_text_533 = line_text_533[len(prompt_534):]
      endif
      let text_529 .= " " . line_text_533
      let line_532 += 1
    endfor
  else
    let text_529 = join(s:line_split(selected_528)," ")
  endif
  return ieie#send_text(a:opener,a:mark,text_529)
endfunction

function! ieie#send_text(Opener,mark,text)
  let mode_535 = mode()
  let bufnum_536 = bufnr("%")
  if "" is (getbufvar(bufnum_536,a:mark))
    call ieie#mark_back_to_window("_send_text")
    if (type(a:Opener)==s:dict_type_483)
      call a:Opener.func()
    else
      call a:Opener()
    endif
  endif
  let bufnum_537 = bufnr("%")
  if !(ieie#execute(a:text,bufnum_537,0))
    call ieie#check_output(ieie#get_context(bufnum_537),1000)
  endif
  if "" is (getbufvar(bufnum_536,a:mark))
    call ieie#back_to_marked_window("_send_text")
  endif
  if mode_535 ==# "n"
    stopinsert
  endif
endfunction

function! ieie#count_window(kind,val)
  let c_538 = 0
  for i_539 in range(0,winnr("$"))
    let n_540 = winbufnr(i_539)
    if a:kind ==# "filetype"
      if (getbufvar(n_540,"&filetype")) ==# a:val
        let c_538 += 1
      endif
    elseif a:kind ==# "let"
      if getbufvar(n_540,a:val)
        let c_538 += 1
      endif
    endif
  endfor
  return c_538
endfunction

function! ieie#move_to_buffer(bufnum)
  for i_541 in range(0,winnr("$"))
    let n_542 = winbufnr(i_541)
    if a:bufnum == n_542
      if i_541 != 0
        execute i_541 "wincmd w"
      endif
      return n_542
    endif
  endfor
  return 0
endfunction

function! ieie#move_to_window(kind,val)
  for i_543 in range(0,winnr("$"))
    let n_544 = winbufnr(i_543)
    if ((a:kind ==# "filetype")?((getbufvar(n_544,"&filetype")) ==# a:val) : (((a:kind ==# "let")?(getbufvar(n_544,a:val)) : (0))))
      if i_543 != 0
        execute i_543 "wincmd w"
      endif
      return n_544
    endif
  endfor
  return 0
endfunction

function! ieie#find_buffer(kind,val)
  for i_545 in range(0,winnr("$"))
    let n_546 = winbufnr(i_545)
    if ((a:kind ==# "filetype")?((getbufvar(n_546,"&filetype")) ==# a:val) : (((a:kind ==# "let")?(getbufvar(n_546,a:val)) : (0))))
      return n_546
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
  let mark_547 = get(a:000,0,"_ref_back")
  for t_548 in range(1,tabpagenr("$"))
    for w_549 in range(1,winnr("$"))
      if gettabwinvar(t_548,w_549,mark_547)
        execute "tabnext" t_548
        execute w_549 "wincmd w"
        execute "unlet! w:" . mark_547
      endif
    endfor
  endfor
endfunction

