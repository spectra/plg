#!/usr/bin/make -f 
TEMPDIR := $(shell mktemp -d --tmpdir installed.plg.XXXXXXXX)

clean:
	rm -rf /tmp/installed.plg*
	rm -f plg
	rm -f plg.1

build:
	echo ${TEMPDIR}
	cp ./plg.sh $(TEMPDIR)/runme.sh
	cp ./template.odt ${TEMPDIR}
	shar ${TEMPDIR} > plg.1
	sed -e 's|exit 0|cd ${TEMPDIR}; ./runme.sh; cd -; exit 0|' plg.1 > plg
	rm plg.1
	chmod a+x plg

install: plg
	install plg /usr/bin

uninstall:
	rm -rf /usr/bin/plg
