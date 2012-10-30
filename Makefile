.PHONY: all

GOSH           = "gosh"
GENVISE        = "/ram/gprog/vise/genvise.scm"

VIMFILES = autoload/gosh_repl.vim 
GENERATED = $(VIMFILES)

#generate vise -> vim file
.SUFFIXES:.vise .vim

.vise.vim:
	$(GOSH) $(GENVISE) -o $(addsuffix .vim, $(basename $<)) $<


CONFIG_GENERATED = Makefile

all : $(VIMFILES)

autoload/gosh_repl.vim: autoload/gosh_repl.vise

clean :
	rm $(GENERATED)
