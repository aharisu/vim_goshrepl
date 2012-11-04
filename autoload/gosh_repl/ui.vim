" Generated automatically DO NOT EDIT

function! s:SID_PREFIX_376()
  return matchstr(expand('<sfile>'),'<SNR>\d\+_\zeSID_PREFIX_376$')
endfunction

let s:gosh_context = {}

let s:updatetime_save = &updatetime

let b:lispwords = ""

function! gosh_repl#ui#open_new_repl(...)
  let bufnum_373 = s:move_to_window("filetype","gosh-repl")
  if bufnum_373
    call cursor(line("$"),col("$"))
  else
    silent! execute s:get_buffer_open_cmd(get(a:000,0,g:gosh_buffer_direction))
    enew
    let bufnum_374 = bufnr("%")
    let ctx_375 = gosh_repl#create_gosh_context(function(s:SID_PREFIX_376() . 'insert_output'),function(s:SID_PREFIX_376() . 'exit_callback'))
    call s:initialize_context(bufnum_374,ctx_375)
    call s:initialize_buffer()
    call gosh_repl#check_output(ctx_375,250)
    unlet s:gosh_context[bufnum_374]
    let bufnum_377 = bufnr("%")
    let s:gosh_context[bufnum_377] = ctx_375
    let ctx_375["context__bufnr"] = bufnum_377
  endif
  startinsert!
endfunction

function! gosh_repl#ui#open_new_repl_with_buffer(...)
  let cur_bufnum_378 = bufnr("%")
  silent! execute s:get_buffer_open_cmd(get(a:000,0,g:gosh_buffer_direction))
  enew
  let bufnum_379 = bufnr("%")
  let ctx_380 = gosh_repl#create_gosh_context_with_buf(function(s:SID_PREFIX_376() . 'insert_output'),cur_bufnum_378,function(s:SID_PREFIX_376() . 'exit_callback'))
  call s:initialize_context(bufnum_379,ctx_380)
  call s:initialize_buffer()
  call gosh_repl#check_output(ctx_380,250)
  unlet s:gosh_context[bufnum_379]
  let bufnum_381 = bufnr("%")
  let s:gosh_context[bufnum_381] = ctx_380
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
  let bufnum_382 = bufnr("%")
  if bufnum_382 != a:ctx["context__bufnr"]
    call s:mark_back_to_window("_output")
    call s:move_to_buffer(a:ctx["context__bufnr"])
  endif
  let col_383 = col(".")
  let line_384 = line(".")
  let cur_line_text_385 = getline(line_384)
  let text_list_386 = split(a:text,"\n")
  let prompt_387 = ""
  if a:text[-1] ==# "\n"
    call add(text_list_386,cur_line_text_385)
  else
    let prompt_387 = text_list_386[-1]
    let col_383 += (len(prompt_387))
    let text_list_386[-1] .= cur_line_text_385
  endif
  for text_388 in text_list_386
    call setline(line_384,text_388)
    let line_384 += 1
  endfor
  let line_384 -= 1
  if !(empty(prompt_387))
    let a:ctx["prompt_history"][line_384] = prompt_387
  endif
  call cursor(line_384,col_383)
  call winline()
  if bufnum_382 != a:ctx["context__bufnr"]
    call s:back_to_marked_window("_output")
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
  call s:buf_leave()
endfunction

function! s:initialize_buffer()
  let cap_389 = "[gosh REPL"
  let c_390 = s:count_window("filetype","gosh-repl")
  let cap_391 = (((c_390)?cap_389 . "-" . (c_390 + 1) : cap_389)) . "]"
  edit `=cap_391`
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
  call gosh_repl#mapping#initialize()
endfunction

function! gosh_repl#ui#get_context(bufnr)
  return s:gosh_context[a:bufnr]
endfunction

function! s:unload_buffer()
  if has_key(s:gosh_context,bufnr("%"))
    let ctx_392 = s:gosh_context[bufnr("%")]
    let ctx_392["context__is_buf_closed"] = 1
    call gosh_repl#destry_gosh_context(ctx_392)
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
  for ctx_393 in values(s:gosh_context)
    call gosh_repl#check_output(ctx_393,a:timeout)
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
  let repl_bufnum_394 = s:find_buffer("filetype","gosh-repl")
  if repl_bufnum_394
    let cur_bufnum_395 = bufnr("%")
    if cur_bufnum_395 != repl_bufnum_394
      call s:mark_back_to_window()
      call s:move_to_window("filetype","gosh-repl")
    endif
    % delete _
    let bufnum_396 = bufnr("%")
    if has_key(s:gosh_context,bufnum_396)
      call gosh_repl#destry_gosh_context(s:gosh_context[bufnum_396])
      let ctx_397 = gosh_repl#create_gosh_context(function(s:SID_PREFIX_376() . 'exit_callback'))
      let ctx_397["context__bufnr"] = bufnum_396
      let s:gosh_context[bufnum_396] = ctx_397
      call gosh_repl#check_output(ctx_397,150)
    endif
    if cur_bufnum_395 != repl_bufnum_394
      call s:back_to_marked_window()
    endif
  else
    echohl WarningMsg
    echomsg "use only in the GoshREPL buffer"
    echohl None
  endif
endfunction

function! gosh_repl#ui#execute(text,bufnum,is_insert)
  let ctx_398 = gosh_repl#ui#get_context(a:bufnum)
  if (bufnr("%")) != a:bufnum
    call s:mark_back_to_window("_execute")
    call s:move_to_buffer(a:bufnum)
  endif
  call gosh_repl#execute_text(ctx_398,a:text)
  execute ":$ normal o"
  let l_399 = line(".")
  call setline(l_399,(repeat(" ",lispindent(l_399))) . (getline(l_399)))
  let outputP_400 = gosh_repl#check_output(ctx_398,100)
  let ctx_398["_input_history_index"] = 0
  if (bufnr("%")) != a:bufnum
    call s:back_to_marked_window("_execute")
  else
    startinsert!
  endif
  return outputP_400
endfunction

function! s:line_split(text_block)
  return map(split(a:text_block,"\n"),'substitute(v:val,"^[\t ]*","","")')
endfunction

function! s:get_visual_block()
  let tmp_401 = @@
  silent normal gvy
  let temp372_402 = @@
  let @@ = tmp_401
  return temp372_402
endfunction

function! gosh_repl#ui#send_text_block()range
  let v_403 = visualmode()
  let selected_404 = s:get_visual_block()
  let text_405 = ""
  if (&filetype ==# "gosh-repl") && (v_403 ==# "v") && (v_403 ==# "V")
    let bufnum_406 = bufnr("%")
    let ctx_407 = gosh_repl#ui#get_context(bufnum_406)
    let line_408 = a:firstline
    for line_text_409 in s:line_split(selected_404)
      let prompt_410 = gosh_repl#get_prompt(ctx_407,line_408)
      if line_text_409 =~# "^" . prompt_410
        let line_text_409 = line_text_409[len(prompt_410):]
      endif
      let text_405 .= " " . line_text_409
      let line_408 += 1
    endfor
  else
    let text_405 = join(s:line_split(selected_404)," ")
  endif
  call gosh_repl#ui#send_text(text_405)
endfunction

function! gosh_repl#ui#send_text(text)
  let mode_411 = mode()
  let filetype_412 = &filetype
  if filetype_412 !=# "gosh-repl"
    call s:mark_back_to_window("_send_text")
    call gosh_repl#ui#open_new_repl()
  endif
  let bufnum_413 = bufnr("%")
  if !(gosh_repl#ui#execute(a:text,bufnum_413,0))
    call gosh_repl#check_output(gosh_repl#ui#get_context(bufnum_413),1000)
  endif
  if filetype_412 !=# "gosh-repl"
    call s:back_to_marked_window("_send_text")
  endif
  if mode_411 ==# "n"
    stopinsert
  endif
endfunction

function! gosh_repl#ui#show_all_line()
  let repl_bufnum_414 = s:find_buffer("filetype","gosh-repl")
  if repl_bufnum_414
    let nr_415 = s:move_to_window("let","gosh_repl_all_line")
    if nr_415
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
    let ctx_416 = gosh_repl#ui#get_context(repl_bufnum_414)
    let line_417 = 1
    for text_418 in ctx_416["lines"]
      call setline(line_417,(repeat(" ",lispindent(line_417))) . (s:strtrim(text_418)))
      let line_417 += 1
      execute "normal o"
      stopinsert
    endfor
    execute line_417 "delete _"
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
  let c_419 = 0
  for i_420 in range(0,winnr("$"))
    let n_421 = winbufnr(i_420)
    if a:kind ==# "filetype"
      if (getbufvar(n_421,"&filetype")) ==# a:val
        let c_419 += 1
      endif
    elseif a:kind ==# "let"
      if getbufvar(n_421,a:val)
        let c_419 += 1
      endif
    endif
  endfor
  return c_419
endfunction

function! s:move_to_buffer(bufnum)
  for i_422 in range(0,winnr("$"))
    let n_423 = winbufnr(i_422)
    if a:bufnum == n_423
      if i_422 != 0
        execute i_422 "wincmd w"
      endif
      return n_423
    endif
  endfor
  return 0
endfunction

function! s:move_to_window(kind,val)
  for i_424 in range(0,winnr("$"))
    let n_425 = winbufnr(i_424)
    if ((a:kind ==# "filetype")?((getbufvar(n_425,"&filetype")) ==# a:val) : (((a:kind ==# "let")?(getbufvar(n_425,a:val)) : (0))))
      if i_424 != 0
        execute i_424 "wincmd w"
      endif
      return n_425
    endif
  endfor
  return 0
endfunction

function! s:find_buffer(kind,val)
  for i_426 in range(0,winnr("$"))
    let n_427 = winbufnr(i_426)
    if ((a:kind ==# "filetype")?((getbufvar(n_427,"&filetype")) ==# a:val) : (((a:kind ==# "let")?(getbufvar(n_427,a:val)) : (0))))
      return n_427
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
  let mark_428 = get(a:000,0,"_ref_back")
  for t_429 in range(1,tabpagenr("$"))
    for w_430 in range(1,winnr("$"))
      if gettabwinvar(t_429,w_430,mark_428)
        execute "tabnext" t_429
        execute w_430 "wincmd w"
        execute "unlet! w:" . mark_428
      endif
    endfor
  endfor
endfunction

function! s:strtrim(text)
  return substitute(copy(a:text),'^\s*',"","")
endfunction

