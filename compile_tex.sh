#!/bin/sh

# recompiles term papers and thesis chapters in latex
# 2012 by Ian D Brunton < iandbrunton at gmail dot com >

# usage: COURSE=x1/5613 compile_tex.sh
# usage: COURSE=thesis/ch1 PAPER=draft1.tex compile_tex.sh
# usage: BIBDIR=

src_dir=$HOME/Dropbox/docs/school/"${COURSE:-thesis}"
PAPER=${PAPER:-paper.tex}
BIBDIR=${BIBDIR:-sources}

cat $src_dir/_header.tex $src_dir/$PAPER $src_dir/_footer.tex > ./paper.tex
cat $src_dir/$BIBDIR/*.bib > ./sources.bib

latex paper.tex
bibtex paper
latex paper.tex
dvipdf paper.dvi
