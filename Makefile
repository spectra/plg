#!/usr/bin/make -f 
clean:
	rm -f plg.sh
	mv template.odt template
	rm -f *.odt
	mv template template.odt

build:
	./addpayload.sh template.odt

install: plg.sh
	install plg.sh /usr/bin

uninstall:
	rm -rf /usr/bin/plg.sh
