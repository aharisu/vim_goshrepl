.PHONY: all

GOSH           = "gosh"
GENVISE        = "/ram/gprog/vise/genvise.scm"

VIMFILES = autoload/gosh_repl.vim autoload/gosh_repl/ui.vim
GENERATED = $(VIMFILES)

#generate vise -> vim file
.SUFFIXES:.vise .vim

.vise.vim:
	$(GOSH) $(GENVISE) -o $(addsuffix .vim, $(basename $<)) $<


CONFIG_GENERATED = Makefile

all : $(VIMFILES)

autoload/gosh_repl.vim: autoload/gosh_repl.vise

autoload/gosh_repl/ui.vim: autoload/gosh_repl/ui.vise

clean :
	rm $(GENERATED)
