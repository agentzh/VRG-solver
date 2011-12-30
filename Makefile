PERL_BIN := E:/perl/bin
PERL_LIB := E:/perl/site/lib

sample_vrg_files := $(wildcard sample/*.vrg)
sample_png_files := $(patsubst %.vrg,%.png,$(sample_vrg_files))

xpro := perl xprolog/xpro.pl
xclp := xclips -I knowledge -c
vrg_run := perl -Ilib script/vrg-run.pl

rm_f = perl -MExtUtils::Command -e rm_f
mv_f = perl -MExtUtils::Command -e mv
cp_f = perl -MExtUtils::Command -e cp

xpro_files := $(wildcard xprolog/*.xpro)
pro_files  := $(patsubst %.xpro,%.pro, $(xpro_files))

clp_files  := $(patsubst %,knowledge/%,vectorize.clp vector-eval.clp \
	anti-vectorize.clp goal-match.clp)

vpath %.xclp knowledge
vpath %.grammar grammar
vpath %.pl script xprolog

all: clips_all

clips_all: lib/VRG/Compiler.pm $(clp_files)

prolog_all: $(pro_files)

lib/VRG/Compiler.pm: vrgs.grammar
	perl -s -MParse::RecDescent - -RD_HINT $< VRG::Compiler
	$(mv_f) Compiler.pm $@

%.pro: %.xpro xprolog/xpro.pl
	$(xpro) $<

knowledge/vectorize.clp: preprocess.xclp

%.clp: %.xclp vrg-sugar.xclp
	$(xclp) $<

testprolog: prolog_all
	prove -Ilib xprolog/*.t

testall: prolog_all clips_all
	prove -Ilib t/*.t xprolog/*.t

test: clips_all
	prove -Ilib t/*.t

clean:
	$(rm_f) xprolog/*.pro xprolog/0*.xpro 0*.xclp *.clp *.vrg \
		sample/*.clp sample/*.xclp *.png
	clips-cover -d

veryclean: clean
	$(rm_f) lib/VRG/Compiler.pm \
		knowledge/*.clp

sample: $(sample_png_files)

sample/%.png: sample/%.vrg clips_all
	$(vrg_run) $<

install:
	pl2bat script/xclips.pl script/clips-cover.pl
	$(cp_f) script/xclips.bat $(PERL_BIN)
	$(cp_f) script/clips-cover.bat $(PERL_BIN)
	$(cp_f) lib/VRG/Compiler.pm $(PERL_LIB)/VRG
