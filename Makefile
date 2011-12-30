sample_vrg_files := $(wildcard sample/*.vrg)
sample_png_files := $(patsubst %.vrg,%.png,$(sample_vrg_files))

xpro := perl xprolog/xpro.pl
xclp := xclips -I knowledge -c
vrg_run := perl -Ilib script/vrg-run.pl

xpro_files := $(wildcard xprolog/*.xpro)
pro_files  := $(patsubst %.xpro,%.pro, $(xpro_files))

clp_files  := $(patsubst %,knowledge/%,vectorize.clp vector-eval.clp \
	anti-vectorize.clp goal-match.clp)

vpath %.xclp knowledge
vpath %.grammar grammar
vpath %.pl script xprolog

.PHONY: all clips_all prolog_all clean veryclean doc

all: clips_all

clips_all: lib/VRG/Compiler.pm $(clp_files)

prolog_all: $(pro_files)

lib/VRG/Compiler.pm: vrgs.grammar
	mkdir -p lib/VRG
	perl -s -MParse::RecDescent - -RD_HINT $< VRG::Compiler
	mv Compiler.pm $@

%.pro: %.xpro xprolog/xpro.pl
	$(xpro) $<

knowledge/vectorize.clp: preprocess.xclp

%.clp: %.xclp vrg-sugar.xclp
	$(xclp) $<

testprolog: prolog_all
	prove -I../xclips/lib -Ilib xprolog/*.t

testall: prolog_all clips_all
	prove -I../xclips/lib -Ilib t/*.t xprolog/*.t

doc:
	cd doc && $(MAKE)

test: clips_all
	prove -I../xclips/lib -Ilib t/*.t

clean:
	rm -f xprolog/*.pro xprolog/0*.xpro 0*.xclp *.clp *.vrg \
		sample/*.clp sample/*.xclp *.png
	clips-cover -d

veryclean: clean
	 lib/VRG/Compiler.pm \
		knowledge/*.clp

sample: $(sample_png_files)

sample/%.png: sample/%.vrg clips_all
	$(vrg_run) $<

