PREFIX = /usr
BINDIR = ${PREFIX}/bin
MANDIR = ${PREFIX}/share/man
LIBDIR = ${PREFIX}/lib

docs:
	scdoc <doc/tinyramfs.8.scd >doc/tinyramfs.8

install: doc
	install -Dm755 tinyramfs ${DESTDIR}${BINDIR}/tinyramfs
	install -Dm644 doc/tinyramfs.8 ${DESTDIR}${MANDIR}/man8/tinyramfs.8
	install -d ${DESTDIR}${LIBDIR}
	cp -a lib ${DESTDIR}${LIBDIR}/tinyramfs
