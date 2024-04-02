# TODO:
# https://cm-mail.stanford.edu/pipermail/cmdist/2021-June/008491.html
# (load "repl.scm")

S7SRCDIR = s7
SUBMODULES = $(S7SRCDIR)

include /usr/lib/bash/Makefile.inc

# for loadables.h
INC += -I${loadablesdir}
SHOBJ_LIBS += s7lib.so

.PHONY: sources submodules
sources: submodules
submodules: .gitmodules

.gitmodules: $(foreach submodule,$(SUBMODULES),$(submodule)/.git)

$(foreach submodule,$(SUBMODULES),$(submodule)/.git):
	git submodule update --init $(dir $@)

$(S7SRCDIR)/s7.h $(S7SRCDIR)/s7.c: sources

clean:
	$(RM) s7lib.o s7bash.o s7bash.so

s7bash.o: s7bash.c $(S7SRCDIR)/s7.h

s7bash.so: SHOBJ_LDFLAGS+=-Wl,--as-needed -Wl,-export-dynamic -Wl,-rpath,'$$ORIGIN'
s7bash.so: s7bash.o $(SHOBJ_LIBS)
	$(SHOBJ_LD) $(SHOBJ_LDFLAGS) $(SHOBJ_XLDFLAGS) -o $@ $^ -ldl -lm

test: s7bash.so
	bash -c 'enable -f ./s7bash.so bashs7; bashs7'
           

# I don't know with the implicit rule isn't building this
s7lib.o: CCFLAGS+=-I$(S7SRCDIR) -DWITH_MAIN -Dmain="s7main"
s7lib.o: $(S7SRCDIR)/s7.c
	$(SHOBJ_CC) $(SHOBJ_CFLAGS) $(CCFLAGS) $(INC) -c -o $@ $<

s7lib.so: SHOBJ_LDFLAGS+=-Wl,-export-dynamic
s7lib.so: s7lib.o
	$(SHOBJ_LD) $(SHOBJ_LDFLAGS) $(SHOBJ_XLDFLAGS) -o $@ $^ -ldl -lm

