all: Overview.html KB.html

%.html: %.pod
	podhtm.pl -o $@ --css perl.css $<
