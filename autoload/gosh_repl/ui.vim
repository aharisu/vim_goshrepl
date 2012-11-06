" Generated automatically DO NOT EDIT

function! s:display410()dict
  return gosh_repl#create_gosh_context_with_buf(function(s:SID_PREFIX_408() . 'insert_output'),self['cur_bufnum_409'],function(s:SID_PREFIX_408() . 'exit_callback'))
endfunction

function! s:SID_PREFIX_408()
  return matchstr(expand('<sfile>'),'<SNR>\d\+_\zeSID_PREFIX_408$')
endfunction

function! s:display407()dict
  return gosh_repl#create_gosh_context(function(s:SID_PREFIX_408() . 'insert_output'),function(s:SID_PREFIX_408() . 'exit_callback'))
endfunction

let s:dict_type_404 = type({})

let s:gosh_context = {}

let s:updatetime_save = &updatetime

let b:lispwords = ""

function! s:create_gosh_repl_buffer(open_cmd,Context_Creater)
  silent! execute a:open_cmd
  enew
  let bufnum_402 = bufnr("%")
  let ctx_403 = (type(a:Context_Creater)==s:dict_type_404) ? a:Context_Creater.func() : a:Context_Creater()
  call s:initialize_context(bufnum_402,ctx_403)
  call s:initialize_buffer()
  call gosh_repl#check_output(ctx_403,250)
  unlet s:gosh_context[bufnum_402]
  let bufnum_405 = bufnr("%")
  let s:gosh_context[bufnum_405] = ctx_403
  let ctx_403["context__bufnr"] = bufnum_405
endfunction

function! gosh_repl#ui#open_new_repl(...)
  let bufnum_406 = s:move_to_window("filetype","gosh-repl")
  if bufnum_406
    call cursor(line("$"),col("$"))
  else
    call s:create_gosh_repl_buffer(s:get_buffer_open_cmd(get(a:000,0,g:gosh_buffer_direction)),{'func':function(s:SID_PREFIX_408() . 'display407')})
  endif
  startinsert!
endfunction

function! gosh_repl#ui#open_new_repl_with_buffer(...)
  let cur_bufnum_409 = bufnr("%")
  call s:create_gosh_repl_buffer(s:get_buffer_open_cmd(get(a:000,0,g:gosh_buffer_direction)),{'func':function(s:SID_PREFIX_408() . 'display410'),'cur_bufnum_409':cur_bufnum_409})
  startinsert!
endfunction

function! s:get_buffer_open_cmd(direc)
  if a:direc =~# "^v"
    return g:gosh_buffer_width . ":vs"
  else
    return g:gosh_buffer_height . ":sp"
  endif
endfunction

function! s:initialize_context(bufnum,ctx)
  let a:ctx["context__bufnr"] = a:bufnum
  let a:ctx["_input_history_index"] = 0
  let a:ctx["context__is_buf_closed"] = 0
  let s:gosh_context[a:bufnum] = a:ctx
endfunction

function! s:insert_output(ctx,text)
  if empty(a:text)
    return
  endif
  let bufnum_411 = bufnr("%")
  if bufnum_411 != a:ctx["context__bufnr"]
    call s:mark_back_to_window("_output")
    call s:move_to_buffer(a:ctx["context__bufnr"])
  endif
  let col_412 = col(".")
  let line_413 = line(".")
  let cur_line_text_414 = getline(line_413)
  let text_list_415 = split(a:text,"\n")
  let prompt_416 = ""
  if a:text[-1] ==# "\n"
    call add(text_list_415,cur_line_text_414)
  else
    let prompt_416 = text_list_415[-1]
    let col_412 += (len(prompt_416))
    let text_list_415[-1] .= cur_line_text_414
  endif
  for text_417 in text_list_415
    call setline(line_413,text_417)
    let line_413 += 1
  endfor
  let line_413 -= 1
  if !(empty(prompt_416))
    let a:ctx["prompt_history"][line_413] = prompt_416
  endif
  call cursor(line_413,col_412)
  call winline()
  if bufnum_411 != a:ctx["context__bufnr"]
    return s:back_to_marked_window("_output")
  endif
endfunction

function! s:exit_callback(ctx)
  if !a:ctx["context__is_buf_closed"]
    execute a:ctx["context__bufnr"] "wincmd q"
  endif
  if has_key(s:gosh_context,a:ctx["context__bufnr"])
    unlet s:gosh_context[a:ctx["context__bufnr"]]
  endif
  if 0 == (len(s:gosh_context))
    augroup goshrepl-plugin
      autocmd! *
    augroup END
  endif
  return s:buf_leave()
endfunction

function! s:initialize_buffer()
  let cap_418 = "[gosh REPL"
  let c_419 = s:count_window("filetype","gosh-repl")
  edit `=(((c_419)?cap_418 . "-" . (c_419 + 1) : cap_418)) . "]"`
  setlocal buftype=nofile noswapfile
  setlocal bufhidden=delete
  setlocal nonumber
  setlocal filetype=gosh-repl
  setlocal syntax=gosh-repl
  augroup goshrepl-plugin
    autocmd BufUnload <buffer> call s:unload_buffer()
    autocmd BufEnter <buffer> call s:buf_enter()
    autocmd BufLeave <buffer> call s:buf_leave()
    autocmd CursorHold <buffer> call s:cursor_hold("n")
    autocmd CursorHoldI <buffer> call s:cursor_hold("i")
    autocmd CursorMoved <buffer> call s:check_output(0)
    autocmd CursorMovedI <buffer> call s:check_output(0)
  augroup END
  call s:buf_enter()
  return gosh_repl#mapping#initialize()
endfunction

function! gosh_repl#ui#get_context(bufnr)
  return s:gosh_context[a:bufnr]
endfunction

function! s:unload_buffer()
  if has_key(s:gosh_context,bufnr("%"))
    let ctx_420 = s:gosh_context[bufnr("%")]
    let ctx_420["context__is_buf_closed"] = 1
    return gosh_repl#destry_gosh_context(ctx_420)
  endif
endfunction

function! s:cursor_hold(mode)
  call s:check_output(0)
  if a:mode ==# "n"
    return feedkeys("g\<ESC>","n")
  elseif a:mode ==# "i"
    return feedkeys("a\<BS>","n")
  endif
endfunction

function! s:check_output(timeout)
  for ctx_421 in values(s:gosh_context)
    call gosh_repl#check_output(ctx_421,a:timeout)
  endfor
endfunction

function! s:buf_enter()
  call s:save_updatetime()
  let b:lispwords = &lispwords
  let &lispwords = "lambda,and,or,if,cond,case,define,let,let*,letrec,begin,do,delay,set!,else,=>,quote,quasiquote,unquote,unquote-splicing,define-syntax,let-syntax,letrec-syntax,syntax-rules,%macroexpand,%macroexpand-1,and-let*,current-module,define-class,define-constant,define-generic,define-in-module,define-inline,define-macro,define-method,define-module,eval-when,export,export-all,extend,import,include,lazy,receive,require,select-module,unless,when,with-module,$,$*,$<<,$do,$do*,$lazy,$many-chars,$or,$satisfy,%do-ec,%ec-guarded-do-ec,%first-ec,%guard-rec,%replace-keywords,--,^,^*,^-generator,^.,^_,^a,^b,^c,^d,^e,^f,^g,^h,^i,^j,^k,^l,^m,^n,^o,^p,^q,^r,^s,^t,^u,^w,^v,^x,^y,^z,add-load-path,any?-ec,append-ec,apropos,assert,autoload,begin0,case-lambda,check-arg,cond-expand,cond-list,condition,cut,cute,debug-print,dec!,declare,define-^x,define-cgen-literal,define-cise-expr,define-cise-macro,define-cise-stmt,define-cise-toplevel,define-compiler-macro,define-condition-type,define-record-type,define-values,do-ec,do-ec:do,dolist,dotimes,ec-guarded-do-ec,ec-simplify,every?-ec,export-if-defined,first-ec,fluid-let,fold-ec,fold3-ec,get-keyword*,get-optional,guard,http-cond-receiver,if-let1,inc!,inline-stub,last-ec,let*-values,let-args,let-keywords,let-keywords*,let-optionals*,let-string-start+end,let-values,let/cc,let1,list-ec,make-option-parser,match,match-define,match-lambda,match-lambda*,match-let,match-let*,match-let1,match-letrec,max-ec,min-ec,parameterize,parse-options,pop!,product-ec,program,push!,rec,require-extension,reset,rlet1,rxmatch-case,rxmatch-cond,rxmatch-if,rxmatch-let,set!-values,shift,srfi-42-,srfi-42-char-range,srfi-42-dispatched,srfi-42-do,srfi-42-generator-proc,srfi-42-integers,srfi-42-let,srfi-42-list,srfi-42-parallel,srfi-42-parallel-1,srfi-42-port,srfi-42-range,srfi-42-real-range,srfi-42-string42-until-1,srfi-42-untilfi-42-vectorfi-42-while-1srfi-42-whilefi-42-while-2ax:make-parserssax:make-elem-parser,stream-cons,ssax:make-pi-parsertream-delay,string-append-ec,string-ec,sum-ec,sxml:find-name-separator,syntax-errorx-errorfime,test*,until,unwind-protect,update!,use,use-version,values-ref,vector-ec,vector-of-length-ec,while,with-builder,with-iteratorwith-signal-handlers,with-time-counter,xmac,xmac1"
endfunction

function! s:buf_leave()
  call s:restore_updatetime()
  if !(empty(b:lispwords))
    let &lispwords = b:lispwords
    let b:lispwords = ""
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

function! gosh_repl#ui#clear_buffer()
  let repl_bufnum_422 = s:find_buffer("filetype","gosh-repl")
  if repl_bufnum_422
    let cur_bufnum_423 = bufnr("%")
    if cur_bufnum_423 != repl_bufnum_422
      call s:mark_back_to_window()
      call s:move_to_window("filetype","gosh-repl")
    endif
% delete _
    let bufnum_424 = bufnr("%")
    if has_key(s:gosh_context,bufnum_424)
      call gosh_repl#destry_gosh_context(s:gosh_context[bufnum_424])
      let ctx_425 = gosh_repl#create_gosh_context(function(s:SID_PREFIX_408() . 'exit_callback'))
      let ctx_425["context__bufnr"] = bufnum_424
      let s:gosh_context[bufnum_424] = ctx_425
      call gosh_repl#check_output(ctx_425,150)
    endif
    if cur_bufnum_423 != repl_bufnum_422
      return s:back_to_marked_window()
    endif
  else
    echohl WarningMsg
    echomsg "use only in the GoshREPL buffer"
    echohl None
  endif
endfunction

function! gosh_repl#ui#execute(text,bufnum,is_insert)
  let ctx_426 = gosh_repl#ui#get_context(a:bufnum)
  if (bufnr("%")) != a:bufnum
    call s:mark_back_to_window("_execute")
    call s:move_to_buffer(a:bufnum)
  endif
  call gosh_repl#execute_text(ctx_426,a:text)
  execute ":$ normal o"
  let l_427 = line(".")
  call setline(l_427,(repeat(" ",lispindent(l_427))) . (getline(l_427)))
  let outputP_428 = gosh_repl#check_output(ctx_426,100)
  let ctx_426["_input_history_index"] = 0
  if (bufnr("%")) != a:bufnum
    call s:back_to_marked_window("_execute")
  else
    startinsert!
  endif
  return outputP_428
endfunction

function! s:line_split(text_block)
  return map(split(a:text_block,"\n"),'substitute(v:val,"^[\t ]*","","")')
endfunction

function! s:get_visual_block()
  let tmp_429 = @@
  silent normal gvy
  let temp399_430 = @@
  let @@ = tmp_429
  return temp399_430
endfunction

function! gosh_repl#ui#send_text_block()range
  let v_431 = visualmode()
  let selected_432 = s:get_visual_block()
  let text_433 = ""
  if (&filetype ==# "gosh-repl") && (v_431 ==# "v") && (v_431 ==# "V")
    let bufnum_434 = bufnr("%")
    let ctx_435 = gosh_repl#ui#get_context(bufnum_434)
    let line_436 = a:firstline
    for line_text_437 in s:line_split(selected_432)
      let prompt_438 = gosh_repl#get_prompt(ctx_435,line_436)
      if line_text_437 =~# "^" . prompt_438
        let line_text_437 = line_text_437[len(prompt_438):]
      endif
      let text_433 .= " " . line_text_437
      let line_436 += 1
    endfor
  else
    let text_433 = join(s:line_split(selected_432)," ")
  endif
  return gosh_repl#ui#send_text(text_433)
endfunction

function! gosh_repl#ui#send_text(text)
  let mode_439 = mode()
  let filetype_440 = &filetype
  if filetype_440 !=# "gosh-repl"
    call s:mark_back_to_window("_send_text")
    call gosh_repl#ui#open_new_repl()
  endif
  let bufnum_441 = bufnr("%")
  if !(gosh_repl#ui#execute(a:text,bufnum_441,0))
    call gosh_repl#check_output(gosh_repl#ui#get_context(bufnum_441),1000)
  endif
  if filetype_440 !=# "gosh-repl"
    call s:back_to_marked_window("_send_text")
  endif
  if mode_439 ==# "n"
    stopinsert
  endif
endfunction

function! gosh_repl#ui#show_all_line()
  let repl_bufnum_442 = s:find_buffer("filetype","gosh-repl")
  if repl_bufnum_442
    let nr_443 = s:move_to_window("let","gosh_repl_all_line")
    if nr_443
% delete _
    else
      execute s:calc_split_window_direction(bufnr("%")) " split"
      enew
      edit `=('[gosh REPL lines]')`
      setlocal buftype=nofile noswapfile
      setlocal bufhidden=delete
      setlocal filetype=scheme
      setlocal syntax=scheme
      let b:gosh_repl_all_line = 1
    endif
    let ctx_444 = gosh_repl#ui#get_context(repl_bufnum_442)
    let line_445 = 1
    for text_446 in ctx_444["lines"]
      call setline(line_445,(repeat(" ",lispindent(line_445))) . (s:strtrim(text_446)))
      let line_445 += 1
      execute "normal o"
      stopinsert
    endfor
    execute line_445 "delete _"
  else
    echohl WarningMsg
    echomsg "gosh-repl buffer not found."
    echohl None
  endif
endfunction

function! s:calc_split_window_direction(bufnum)
  if ((winwidth(a:bufnum)) * 2) < ((winheight(a:bufnum)) * 5)
    return ""
  else
    return "vertical"
  endif
endfunction

function! s:count_window(kind,val)
  let c_447 = 0
  for i_448 in range(0,winnr("$"))
    let n_449 = winbufnr(i_448)
    if a:kind ==# "filetype"
      if (getbufvar(n_449,"&filetype")) ==# a:val
        let c_447 += 1
      endif
    elseif a:kind ==# "let"
      if getbufvar(n_449,a:val)
        let c_447 += 1
      endif
    endif
  endfor
  return c_447
endfunction

function! s:move_to_buffer(bufnum)
  for i_450 in range(0,winnr("$"))
    let n_451 = winbufnr(i_450)
    if a:bufnum == n_451
      if i_450 != 0
        execute i_450 "wincmd w"
      endif
      return n_451
    endif
  endfor
  return 0
endfunction

function! s:move_to_window(kind,val)
  for i_452 in range(0,winnr("$"))
    let n_453 = winbufnr(i_452)
    if ((a:kind ==# "filetype")?((getbufvar(n_453,"&filetype")) ==# a:val) : (((a:kind ==# "let")?(getbufvar(n_453,a:val)) : (0))))
      if i_452 != 0
        execute i_452 "wincmd w"
      endif
      return n_453
    endif
  endfor
  return 0
endfunction

function! s:find_buffer(kind,val)
  for i_454 in range(0,winnr("$"))
    let n_455 = winbufnr(i_454)
    if ((a:kind ==# "filetype")?((getbufvar(n_455,"&filetype")) ==# a:val) : (((a:kind ==# "let")?(getbufvar(n_455,a:val)) : (0))))
      return n_455
    endif
  endfor
  return 0
endfunction

function! s:mark_back_to_window(...)
  execute "let w:" . (get(a:000,0,"_ref_back")) . " = 1"
endfunction

function! s:unmark_back_to_window()
  unlet! w:_ref_back
endfunction

function! s:back_to_marked_window(...)
  let mark_456 = get(a:000,0,"_ref_back")
  for t_457 in range(1,tabpagenr("$"))
    for w_458 in range(1,winnr("$"))
      if gettabwinvar(t_457,w_458,mark_456)
        execute "tabnext" t_457
        execute w_458 "wincmd w"
        execute "unlet! w:" . mark_456
      endif
    endfor
  endfor
endfunction

function! s:strtrim(text)
  return substitute(copy(a:text),'^\s*',"","")
endfunction

