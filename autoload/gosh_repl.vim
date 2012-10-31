" Generated automatically DO NOT EDIT

function! s:display343()dict
  echohl Error
  echomsg join((type(self['proc_339']["stdout"]["read_lines"])==s:dict_type_342) ? self['proc_339']["stdout"]["read_lines"].func() : self['proc_339']["stdout"]["read_lines"](),"\n")
  echohl None
  return vimproc#popen2("gosh -b" . " -u gauche.interactive" . " -I" . s:gosh_repl_directory . "/gosh_repl" . " -e \"(begin " . s:enable_auto_use_exp() . " (include \\\"" . s:gosh_repl_body_path . "\\\") (exit))\"")
endfunction

let s:dict_type_342 = type({})

let s:gosh_repl_directory = substitute(expand("<sfile>:p:h"),"\\","/","g")

let s:gosh_repl_body_path = s:gosh_repl_directory . "/gosh_repl/repl.scm"

function! s:enable_auto_use_exp()
  if g:gosh_enable_auto_use
    return "(define *enable-auto-use* #t)"
  else
    return "(define *enable-auto-use* #f)"
  endif
endfunction

function! s:create_context(proc,printer,exit_callback)
  return {'proc' : a:proc,'printer' : a:printer,'lines' : [],'prompt_history' : {},'exit_callback' : a:exit_callback}
endfunction

function! gosh_repl#create_gosh_context(Printer,...)
  return s:create_context(vimproc#popen2("gosh -b" . " -u gauche.interactive" . " -I" . s:gosh_repl_directory . "/gosh_repl/" . " -e \"(begin " . s:enable_auto_use_exp() . " (include \\\"" . s:gosh_repl_body_path . "\\\") (exit))\""),a:Printer,get(a:000,0,0))
endfunction

function! gosh_repl#create_gosh_context_with_buf(Printer,bufnr,...)
  let proc_339 = vimproc#popen2("gosh -b" . " -u gauche.interactive" . " -I" . s:gosh_repl_directory . "/gosh_repl/")
  let exception_340 = 0
  try
    for line_341 in getbufline(a:bufnr,1,"$")
      if (type(proc_339["stdin"]["write"])==s:dict_type_342)
        call proc_339["stdin"]["write"].func(line_341 . "\n")
      else
        call proc_339["stdin"]["write"](line_341 . "\n")
      endif
    endfor
    sleep 100ms
    if (type(proc_339["stdin"]["write"])==s:dict_type_342)
      call proc_339["stdin"]["write"].func("(begin " . s:enable_auto_use_exp() . " (include \"" . s:gosh_repl_body_path . "\"))\n")
    else
      call proc_339["stdin"]["write"]("(begin " . s:enable_auto_use_exp() . " (include \"" . s:gosh_repl_body_path . "\"))\n")
    endif
  catch
    let exception_340 = 1
  endtry
  sleep 100ms
  if !(proc_339["is_valid"]) || !(proc_339["stdin"]["is_valid"]) || (proc_339["stdin"]["eof"]) || !(proc_339["stdout"]["is_valid"]) || (proc_339["stdout"]["eof"])
    let exception_340 = 1
  endif
  return s:create_context(((exception_340)?{'func':function('s:display343'),'proc_339':proc_339}.func() : proc_339),a:Printer,get(a:000,0,0))
endfunction

function! gosh_repl#destry_gosh_context(context)
  if (type(a:context["proc"]["stdin"]["close"])==s:dict_type_342)
    call a:context["proc"]["stdin"]["close"].func()
  else
    call a:context["proc"]["stdin"]["close"]()
  endif
  if (type(a:context["proc"]["stdout"]["close"])==s:dict_type_342)
    call a:context["proc"]["stdout"]["close"].func()
  else
    call a:context["proc"]["stdout"]["close"]()
  endif
  return s:run_exit_callback(a:context)
endfunction

function! s:run_exit_callback(context)
  if (a:context["exit_callback"]) isnot 0
    return (type(a:context["exit_callback"])==s:dict_type_342) ? a:context["exit_callback"].func(a:context) : a:context["exit_callback"](a:context)
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
    return s:run_exit_callback(a:context)
  else
    call add(a:context["lines"],a:text)
    return (type(a:context["proc"]["stdin"]["write"])==s:dict_type_342) ? a:context["proc"]["stdin"]["write"].func(((a:text !~# "\n$")?a:text . "\n" : a:text)) : a:context["proc"]["stdin"]["write"](((a:text !~# "\n$")?a:text . "\n" : a:text))
  endif
endfunction

function! gosh_repl#check_output(context,...)
  if !(a:context["proc"]["is_valid"]) || !(a:context["proc"]["stdout"]["is_valid"]) || (a:context["proc"]["stdout"]["eof"])
    call s:run_exit_callback(a:context)
    return 0
  else
    let out_344 = s:read_output(a:context,get(a:000,0,0))
    if !empty(out_344)
      if (type(a:context["printer"])==s:dict_type_342)
        call a:context["printer"].func(a:context,out_344)
      else
        call a:context["printer"](a:context,out_344)
      endif
      return 1
    else
      return 0
    endif
  endif
endfunction

function! s:read_output(context,timeout)
  let port_345 = a:context["proc"]["stdout"]
  let out_346 = ""
  let res_347 = (type(port_345["read"])==s:dict_type_342) ? port_345["read"].func(-1,a:timeout) : port_345["read"](-1,a:timeout)
  let recursion_348 = 1
  while recursion_348
    let recursion_348 = 0
    if empty(res_347)
      return out_346
    else
      let recursion_348 = 1
      let out_346 = out_346 . res_347
      let res_347 = (type(port_345["read"])==s:dict_type_342) ? port_345["read"].func(-1,15) : port_345["read"](-1,15)
    endif
  endwhile
endfunction

function! gosh_repl#get_prompt(context,line)
  if has_key(a:context,"prompt_history")
    return get(a:context["prompt_history"],a:line,"")
  else
    return ""
  endif
endfunction

