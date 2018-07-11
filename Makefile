include config.mk
PKG_NAME = dvtm-config

RPM_DIRS = BUILD RPMS SOURCES SPECS SRPMS

SRC = dvtm-config.c vt.c ini.c
DIST_FILES = LICENSE Makefile README.md testsuite.py test-bashrc testsuite.sh config.def.h config.mk \
		vt.h forkpty-aix.c forkpty-sunos.c tile.c bstack.c \
		ini.h tstack.c vstack.c grid.c fullscreen.c fibonacci.c \
		dvtm-config-status dvtm-config.info dvtm-config.1
OBJ = ${SRC:.c=.o}

all: clean options dvtm-config

options:
	@echo $(PKG_NAME) build options:
	@echo "CFLAGS   = ${CFLAGS}"
	@echo "LDFLAGS  = ${LDFLAGS}"
	@echo "CC       = ${CC}"

config.h:
	cp config.def.h config.h

.c.o:
	@echo CC $<
	@${CC} -c ${CFLAGS} $<

${OBJ}: config.h config.mk

dvtm-config: ${OBJ}
	@echo CC -o $@
	@${CC} -o $@ ${OBJ} ${LDFLAGS}

debug: clean
	@make CFLAGS='${DEBUG_CFLAGS}'

clean-rpm:
	@rm -rf $(RPM_DIRS)

clean:
	@echo cleaning
	@rm -f dvtm-config ${OBJ} $(PKG_NAME)-${VERSION}.tar.gz
	@rm -rf $(RPM_DIRS)

dist: clean
	@echo creating dist tarball
	@mkdir -p $(PKG_NAME)-${VERSION}
	@cp -R $(SRC) $(DIST_FILES) \
		 $(PKG_NAME)-${VERSION}
	@tar -cf $(PKG_NAME)-${VERSION}.tar $(PKG_NAME)-${VERSION}
	@gzip $(PKG_NAME)-${VERSION}.tar
	@rm -rf $(PKG_NAME)-${VERSION}

$(RPM_DIRS)/:
	@mkdir -p ~/rpmbuild/$@

dist-rpm: clean $(RPM_DIRS)/
	@echo creating dist tarball
	@mkdir -p $(PKG_NAME)-${VERSION}
	@cp -R $(SRC) $(DIST_FILES) \
		 $(PKG_NAME)-${VERSION}
	@tar -cf ~/rpmbuild/SOURCES/$(PKG_NAME)-${VERSION}.tar $(PKG_NAME)-${VERSION}
	@gzip ~/rpmbuild/SOURCES/$(PKG_NAME)-${VERSION}.tar
	@rm -rf $(PKG_NAME)-${VERSION}
	@cp $(PKG_NAME).spec ~/rpmbuild/SPECS
	@cp dvtm-config-0.16-build.patch  ~/rpmbuild/SOURCES
	@rpmbuild -v -bb --clean ~/rpmbuild/SPECS/$(PKG_NAME).spec

install: dvtm-config
	@echo stripping executable
	@${STRIP} dvtm-config
	@echo installing executable file to ${DESTDIR}${PREFIX}/bin
	@mkdir -p ${DESTDIR}${PREFIX}/bin
	@cp -f dvtm-config ${DESTDIR}${PREFIX}/bin
	@chmod 755 ${DESTDIR}${PREFIX}/bin/dvtm-config
	@cp -f dvtm-config-status ${DESTDIR}${PREFIX}/bin
	@chmod 755 ${DESTDIR}${PREFIX}/bin/dvtm-config-status
	@echo installing manual page to ${DESTDIR}${MANPREFIX}/man1
	@mkdir -p ${DESTDIR}${MANPREFIX}/man1
	@sed "s/VERSION/${VERSION}/g" < dvtm-config.1 > ${DESTDIR}${MANPREFIX}/man1/dvtm-config.1
	@chmod 644 ${DESTDIR}${MANPREFIX}/man1/dvtm-config.1
	@echo installing terminfo description
	@TERMINFO=${TERMINFO} tic -s dvtm-config.info

uninstall:
	@echo removing executable file from ${DESTDIR}${PREFIX}/bin
	@rm -f ${DESTDIR}${PREFIX}/bin/dvtm-config
	@rm -f ${DESTDIR}${PREFIX}/bin/dvtm-config-status
	@echo removing manual page from ${DESTDIR}${MANPREFIX}/man1
	@rm -f ${DESTDIR}${MANPREFIX}/man1/dvtm-config.1

.PHONY: all options clean dist install uninstall debug
