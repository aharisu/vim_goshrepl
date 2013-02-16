.PHONY: all

GOSH           = "gosh"
GENVISE        = "/ram/gprog/vise/autoload/genvise.scm"

VIMFILES = autoload/ieie.vim autoload/ieie_mapping.vim \
	   autoload/gosh_repl.vim \
	   autoload/ghcieie.vim
GENERATED = $(VIMFILES)

#generate vise -> vim file
.SUFFIXES:.vise .vim

.vise.vim:
	$(GOSH) $(GENVISE) -o $(addsuffix .vim, $(basename $<)) $<


CONFIG_GENERATED = Makefile

all : $(VIMFILES)

autoload/gosh_repl.vim: autoload/gosh_repl.vise

autoload/ghcieie.vim: autoload/ghcieie.vise

autoload/ieie.vim: autoload/ieie.vise

autoload/ieie_mapping.vim: autoload/ieie_mapping.vise

clean :
	rm $(GENERATED)
