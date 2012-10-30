let s:dict_type_335 = type({})

let s:gosh_repl_directory = substitute(expand("<sfile>:p:h"),"\\","/","g")

let s:gosh_repl_body_path = s:gosh_repl_directory . "/gosh_repl/repl.scm"

function! s:enable_auto_use_exp()
  if g:gosh_enable_auto_use
    return "(define *enable-auto-use* #t)"
  else
    return "(define *enable-auto-use* #f)"
  endif
endfunction

function! gosh_repl#create_gosh_context(Printer,...)
  let proc_329 = vimproc#popen2("gosh -b" . " -u gauche.interactive" . " -I" . s:gosh_repl_directory . "/gosh_repl/" . " -e \"(begin " . s:enable_auto_use_exp() . " (include \\\"" . s:gosh_repl_body_path . "\\\") (exit))\"")
  let context_330 = {'proc' : proc_329,'printer' : a:Printer,'lines' : [],'prompt_history' : {}}
  let context_330["exit_callback"] = ((0 < len(a:000))?(a:000[0]) : 0)
  return context_330
endfunction

function! gosh_repl#create_gosh_context_with_buf(Printer,bufnr,...)
  let proc_331 = vimproc#popen2("gosh -b" . " -u gauche.interactive" . " -I" . s:gosh_repl_directory . "/gosh_repl/")
  let exception_332 = 0
  try
    for line_333 in getbufline(a:bufnr,1,"$")
      call proc_331["stdin"]["write"](line_333 . "\n")
    endfor
    sleep 100ms
    call proc_331["stdin"]["write"]("(begin " . s:enable_auto_use_exp() . " (include \"" . s:gosh_repl_body_path . "\"))\n")
  catch
    let exception_332 = 1
  endtry
  sleep 100ms
  if !(proc_331["is_valid"]) || !(proc_331["stdin"]["is_valid"]) || (proc_331["stdin"]["eof"]) || !(proc_331["stdout"]["is_valid"]) || (proc_331["stdout"]["eof"])
    let exception_332 = 1
  endif
  if exception_332
    echohl Error
    echomsg join(proc_331["stdout"]["read_lines"](),"\n")
    echohl None
    let proc_331 = vimproc#popen2("gosh -b" . " -u gauche.interactive" . " -I" . s:gosh_repl_directory . "/gosh_repl" . " -e \"(begin " . s:enable_auto_use_exp() . " (include \\\"" . s:gosh_repl_body_path . "\\\") (exit))\"")
  endif
  return {'proc' : proc_331,'printer' : a:Printer,'lines' : [],'prompt_history' : {},'exit_callback' : ((0 < len(a:000))?(a:000[0]) : 0)}
endfunction

function! gosh_repl#destry_gosh_context(context)
  call a:context["proc"]["stdin"]["close"]()
  call a:context["proc"]["stdout"]["close"]()
  return s:run_exit_callback(a:context)
endfunction

function! s:run_exit_callback(context)
  if (a:context["exit_callback"]) isnot 0
    let Exit_Callback_334 = a:context["exit_callback"]
    return (type(Exit_Callback_334)==s:dict_type_335) ? Exit_Callback_334.func(a:context) : Exit_Callback_334(a:context)
  endif
endfunction

function! gosh_repl#execute_line(context)
  return gosh_repl#execute_text(a:context,gosh_repl#get_line_text(a:context,line(".")))
endfunction

function! gosh_repl#get_line_text(context,num_line)
  return getline(a:num_line)[len(gosh_repl#get_prompt(a:context,a:num_line)):]
endfunction

function! gosh_repl#execute_text(context,text)
  if !(a:context["proc"]["is_valid"]) || !(a:context["proc"]["stdin"]["is_valid"]) || (a:context["proc"]["stdin"]["eof"])
    call s:run_exit_callback(a:context)
    return
  endif
  call add(a:context["lines"],a:text)
  return a:context["proc"]["stdin"]["write"](((a:text !~# "\n$")?a:text . "\n" : a:text))
endfunction

function! gosh_repl#check_output(context,...)
  if !(a:context["proc"]["is_valid"]) || !(a:context["proc"]["stdout"]["is_valid"]) || (a:context["proc"]["stdout"]["eof"])
    call s:run_exit_callback(a:context)
    return 0
  endif
  let out_336 = s:read_output(a:context,((0 < len(a:000))?(a:000[0]) : 0))
  if !empty(out_336)
    let Printer_337 = a:context["printer"]
    if (type(Printer_337)==s:dict_type_335)
      call Printer_337.func(a:context,out_336)
    else
      call Printer_337(a:context,out_336)
    endif
    return 1
  else
    return 0
  endif
endfunction

function! s:read_output(context,timeout)
  let out_338 = ""
  let port_339 = a:context["proc"]["stdout"]
  let res_340 = port_339["read"](-1,a:timeout)
  while !empty(res_340)
    let out_338 = out_338 . res_340
    let res_340 = port_339["read"](-1,15)
  endwhile
  return out_338
endfunction

function! gosh_repl#get_prompt(context,line)
  if has_key(a:context,"prompt_history")
    return get(a:context["prompt_history"],a:line,"")
  else
    return ""
  endif
endfunction

