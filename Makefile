include config.mk

SRC = dvtm-config.c vt.c
OBJ = ${SRC:.c=.o}

all: clean options dvtm-config

options:
	@echo dvtm-config build options:
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

clean:
	@echo cleaning
	@rm -f dvtm-config ${OBJ} dvtm-config-${VERSION}.tar.gz

dist: clean
	@echo creating dist tarball
	@mkdir -p dvtm-config-${VERSION}
	@cp -R LICENSE Makefile README.md testsuite.sh config.def.h config.mk \
		${SRC} vt.h forkpty-aix.c forkpty-sunos.c tile.c bstack.c \
		tstack.c vstack.c grid.c fullscreen.c fibonacci.c \
		dvtm-config-status dvtm-config.info dvtm-config.1 dvtm-config-${VERSION}
	@tar -cf dvtm-config-${VERSION}.tar dvtm-config-${VERSION}
	@gzip dvtm-config-${VERSION}.tar
	@rm -rf dvtm-config-${VERSION}

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
