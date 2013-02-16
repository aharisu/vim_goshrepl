" Generated automatically DO NOT EDIT

function! s:display485()
  return s:open_gosh_proc_with_buf(bufnr("%"))
endfunction

function! s:display484(pa_477)dict
  return s:buffer_open_cmd(get(self['a:000'],0,g:gosh_buffer_direction),a:pa_477)
endfunction

function! s:display483(pa_476)dict
  return s:buffer_open_cmd(get(self['a:000'],0,g:gosh_buffer_direction),a:pa_476)
endfunction

function! s:SID_PREFIX_482()
  return matchstr(expand('<sfile>'),'<SNR>\d\+_\zeSID_PREFIX_482$')
endfunction

let s:dict_type_481 = type({})

let s:gosh_repl_directory = substitute(expand("<sfile>:p:h"),"\\","/","g")

let s:gosh_repl_body_path = s:gosh_repl_directory . "/gosh_repl/repl.scm"

function! s:open_gosh_proc()
  return vimproc#popen2("gosh -b" . " -u gauche.interactive" . " -I" . s:gosh_repl_directory . "/gosh_repl/" . " -e \"(begin " . (((g:gosh_enable_auto_use)?"(define *enable-auto-use* #t)" : "(define *enable-auto-use* #f)")) . " (include \\\"" . s:gosh_repl_body_path . "\\\") (exit))\"")
endfunction

function! s:open_gosh_proc_with_buf(bufnr)
  let proc_478 = vimproc#popen2("gosh -b" . " -u gauche.interactive" . " -I" . s:gosh_repl_directory . "/gosh_repl/")
  let exception_479 = 0
  try
    for line_480 in getbufline(a:bufnr,1,"$")
      if (type(proc_478["stdin"]["write"])==s:dict_type_481)
        call proc_478["stdin"]["write"].func(line_480 . "\n")
      else
        call proc_478["stdin"]["write"](line_480 . "\n")
      endif
    endfor
    sleep 100ms
    if (type(proc_478["stdin"]["write"])==s:dict_type_481)
      call proc_478["stdin"]["write"].func("(begin " . (((g:gosh_enable_auto_use)?"(define *enable-auto-use* #t)" : "(define *enable-auto-use* #f)")) . " (include \"" . s:gosh_repl_body_path . "\") (exit))" . "\n")
    else
      call proc_478["stdin"]["write"]("(begin " . (((g:gosh_enable_auto_use)?"(define *enable-auto-use* #t)" : "(define *enable-auto-use* #f)")) . " (include \"" . s:gosh_repl_body_path . "\") (exit))" . "\n")
    endif
  catch
    let exception_479 = 1
  endtry
  sleep 100ms
  if (!proc_478["is_valid"]) || (!proc_478["stdin"]["is_valid"]) || proc_478["stdin"]["eof"] || (!proc_478["stdout"]["is_valid"]) || proc_478["stdout"]["eof"]
    let exception_479 = 1
  endif
  if exception_479
    echohl Error
    echomsg (join((type(proc_478["stdout"]["read_lines"])==s:dict_type_481) ? proc_478["stdout"]["read_lines"].func() : proc_478["stdout"]["read_lines"](),"\n"))
    echohl None
    return s:open_gosh_proc()
  else
    return proc_478
  endif
endfunction

function! s:buffer_open_cmd(direc,conf)
  if a:direc =~# "^v"
    return g:gosh_buffer_width . ":vs"
  else
    return g:gosh_buffer_height . ":sp"
  endif
endfunction

function! gosh_repl#open_gosh_repl(...)
  return ieie#open_interactive({'caption' : "gosh REPL",'mark' : "ieie_gosh_repl",'filetype' : "gosh-repl",'buffer-enter' : function(s:SID_PREFIX_482() . 'buffer_enter'),'buffer-leave' : function(s:SID_PREFIX_482() . 'buffer_leave'),'buffer-open' : {'func':function(s:SID_PREFIX_482() . 'display483'),'a:000':a:000},'proc' : function(s:SID_PREFIX_482() . 'open_gosh_proc')})
endfunction

function! gosh_repl#open_gosh_repl_with_buffer(...)
  return ieie#open_interactive({'caption' : "gosh REPL",'mark' : "ieie_gosh_repl",'filetype' : "gosh-repl",'buffer-enter' : function(s:SID_PREFIX_482() . 'buffer_enter'),'buffer-leave' : function(s:SID_PREFIX_482() . 'buffer_leave'),'buffer-open' : {'func':function(s:SID_PREFIX_482() . 'display484'),'a:000':a:000},'always-new' : 1,'proc' : function(s:SID_PREFIX_482() . 'display485')})
endfunction

let b:lispwords = ""

function! s:buffer_enter(ctx)
  if (!(exists("b:lispwords"))) || (empty(b:lispwords))
    let b:lispwords = &lispwords
    let &lispwords = "lambda,and,or,if,cond,case,define,let,let*,letrec,begin,do,delay,set!,else,=>,quote,quasiquote,unquote,unquote-splicing,define-syntax,let-syntax,letrec-syntax,syntax-rules,%macroexpand,%macroexpand-1,and-let*,current-module,define-class,define-constant,define-generic,define-in-module,define-inline,define-macro,define-method,define-module,eval-when,export,export-all,extend,import,include,lazy,receive,require,select-module,unless,when,with-module,$,$*,$<<,$do,$do*,$lazy,$many-chars,$or,$satisfy,%do-ec,%ec-guarded-do-ec,%first-ec,%guard-rec,%replace-keywords,--,^,^*,^-generator,^.,^_,^a,^b,^c,^d,^e,^f,^g,^h,^i,^j,^k,^l,^m,^n,^o,^p,^q,^r,^s,^t,^u,^w,^v,^x,^y,^z,add-load-path,any?-ec,append-ec,apropos,assert,autoload,begin0,case-lambda,check-arg,cond-expand,cond-list,condition,cut,cute,debug-print,dec!,declare,define-^x,define-cgen-literal,define-cise-expr,define-cise-macro,define-cise-stmt,define-cise-toplevel,define-compiler-macro,define-condition-type,define-record-type,define-values,do-ec,do-ec:do,dolist,dotimes,ec-guarded-do-ec,ec-simplify,every?-ec,export-if-defined,first-ec,fluid-let,fold-ec,fold3-ec,get-keyword*,get-optional,guard,http-cond-receiver,if-let1,inc!,inline-stub,last-ec,let*-values,let-args,let-keywords,let-keywords*,let-optionals*,let-string-start+end,let-values,let/cc,let1,list-ec,make-option-parser,match,match-define,match-lambda,match-lambda*,match-let,match-let*,match-let1,match-letrec,max-ec,min-ec,parameterize,parse-options,pop!,product-ec,program,push!,rec,require-extension,reset,rlet1,rxmatch-case,rxmatch-cond,rxmatch-if,rxmatch-let,set!-values,shift,srfi-42-,srfi-42-char-range,srfi-42-dispatched,srfi-42-do,srfi-42-generator-proc,srfi-42-integers,srfi-42-let,srfi-42-list,srfi-42-parallel,srfi-42-parallel-1,srfi-42-port,srfi-42-range,srfi-42-real-range,srfi-42-string42-until-1,srfi-42-untilfi-42-vectorfi-42-while-1srfi-42-whilefi-42-while-2ax:make-parserssax:make-elem-parser,stream-cons,ssax:make-pi-parsertream-delay,string-append-ec,string-ec,sum-ec,sxml:find-name-separator,syntax-errorx-errorfime,test*,until,unwind-protect,update!,use,use-version,values-ref,vector-ec,vector-of-length-ec,while,with-builder,with-iteratorwith-signal-handlers,with-time-counter,xmac,xmac1"
  endif
endfunction

function! s:buffer_leave(ctx)
  if (exists("b:lispwords")) && (!(empty(b:lispwords)))
    let &lispwords = b:lispwords
    let b:lispwords = ""
  endif
endfunction

function! gosh_repl#send_text_block()range
  return ieie#send_text_block(function('gosh_repl#open_gosh_repl'),"ieie_gosh_repl")
endfunction

function! gosh_repl#send_text(text)
  return ieie#send_text(function('gosh_repl#open_gosh_repl'),"ieie_gosh_repl",a:text)
endfunction

