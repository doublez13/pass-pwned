PREFIX ?= /usr
DESTDIR ?=
LIBDIR ?= $(PREFIX)/lib
EXTDIR ?= $(DESTDIR)$(LIBDIR)/password-store/extensions

all:
  @echo "There is nothing to compile. Run 'make install' to install pass-pwned"

install:
  @install -v -m 0755 ./pwned.bash $(EXTDIR)/pwned.bash

uninstall:
  @rm -vf $(EXTDIR)/pwned.bash
