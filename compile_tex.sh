#!/bin/sh

# recompiles term papers and thesis chapters in latex
# 2012 by Ian D Brunton < iandbrunton at gmail dot com >

# usage: COURSE=x1/5613 compile_tex.sh
# usage: COURSE=thesis/ch1 PAPER=draft1.tex compile_tex.sh

src_dir=$HOME/Dropbox/docs/school/"${COURSE:-thesis}"
SRC_DOC=${PAPER:-paper.tex}
BIBCMD=${BIBCMD:-biber}
OUTPUT=${OUTPUT:-paper} # no extension

cat $src_dir/_header.tex $src_dir/$SRC_DOC $src_dir/_footer.tex > ./${OUTPUT}.tex

latex ${OUTPUT}.tex
${BIBCMD} ${OUTPUT}
latex ${OUTPUT}.tex
latex ${OUTPUT}.tex
dvipdf ${OUTPUT}.dvi
