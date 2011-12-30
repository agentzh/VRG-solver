all: Overview.html KB.html

%.html: %.pod
	podhtm.pl --index -o $@ --css perl.css $<
