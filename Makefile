include config.mk
PKG_NAME = dvtm-plus
PGM_NAME = $(PKG_NAME)
ifeq (${LOGNAME},)
LOG_DEBUG_FLAGS = ${DEBUG_CFLAGS}
else
LOG_DEBUG_FLAGS = ${DEBUG_CFLAGS} -DLOGNAME="\"${LOGNAME}\""
endif

RPM_DIRS = BUILD BUILDROOT RPMS SOURCES SPECS SRPMS

SRC = dvtm-plus.c vt.c ini.c
DIST_FILES = LICENSE Makefile README.md test-bashrc testsuite.sh config.def.h config.mk \
		vt.h forkpty-aix.c forkpty-sunos.c tile.c bstack.c \
		ini.h tstack.c vstack.c grid.c fullscreen.c fibonacci.c \
		$(PGM_NAME)-status $(PGM_NAME).info $(PGM_NAME).1
OBJ = ${SRC:.c=.o}

all: clean options dvtm-plus

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

dvtm-plus: ${OBJ}
	@echo CC -o $@
	@${CC} -o $@ ${OBJ} ${LDFLAGS}

debug: clean
	@echo "CFLAGS   = ${LOG_DEBUG_FLAGS}"
	@echo "LDFLAGS  = ${LDFLAGS}"
	@make CFLAGS='${LOG_DEBUG_FLAGS}'

clean:
	@echo cleaning
	@rm -f $(PGM_NAME) ${OBJ} $(PKG_NAME)-${VERSION}.tar.gz

dist: clean
	@echo creating dist tarball
	@mkdir -p $(PKG_NAME)-${VERSION}
	@cp -R $(SRC) $(DIST_FILES) \
		 $(PKG_NAME)-${VERSION}
	@tar -cf $(PKG_NAME)-${VERSION}.tar $(PKG_NAME)-${VERSION}
	@gzip $(PKG_NAME)-${VERSION}.tar
	@rm -rf $(PKG_NAME)-${VERSION}

dist-rpm: clean dist
	@rpmdev-setuptree
	@mv $(PKG_NAME)-${VERSION}.tar.gz ~/rpmbuild/SOURCES/
	@cp $(PKG_NAME).spec ~/rpmbuild/SPECS
	@cp dvtm-plus-$(BASE_VERSION)-build.patch  ~/rpmbuild/SOURCES
	@rpmbuild -v -ba --clean ~/rpmbuild/SPECS/$(PKG_NAME).spec

install: dvtm-plus
	@echo stripping executable
	@${STRIP} $(PGM_NAME)
	@echo installing executable file to ${DESTDIR}${PREFIX}/bin
	@mkdir -p ${DESTDIR}${PREFIX}/bin
	@cp -f $(PGM_NAME) ${DESTDIR}${PREFIX}/bin
	@chmod 755 ${DESTDIR}${PREFIX}/bin/$(PGM_NAME)
	@cp -f $(PGM_NAME)-status ${DESTDIR}${PREFIX}/bin
	@chmod 755 ${DESTDIR}${PREFIX}/bin/$(PGM_NAME)-status
	@echo installing manual page to ${DESTDIR}${MANPREFIX}/man1
	@mkdir -p ${DESTDIR}${MANPREFIX}/man1
	@sed "s/VERSION/${VERSION}/g" < $(PGM_NAME).1 > ${DESTDIR}${MANPREFIX}/man1/$(PGM_NAME).1
	@chmod 644 ${DESTDIR}${MANPREFIX}/man1/$(PGM_NAME).1
	@echo installing terminfo description
	@TERMINFO=${TERMINFO} tic -s $(PGM_NAME).info

uninstall:
	@echo removing executable file from ${DESTDIR}${PREFIX}/bin
	@rm -f ${DESTDIR}${PREFIX}/bin/$(PGM_NAME)
	@rm -f ${DESTDIR}${PREFIX}/bin/$(PGM_NAME)-status
	@echo removing manual page from ${DESTDIR}${MANPREFIX}/man1
	@rm -f ${DESTDIR}${MANPREFIX}/man1/$(PGM_NAME).1

.PHONY: all options clean dist install uninstall debug
