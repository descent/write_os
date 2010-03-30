BOOK=WriteOS
SRC=solrexbook.sty utf8.cpx 000-cover.tex 000-preface.tex 000-foreword.tex\
WriteOS.tex 001.tex 002.tex 003.tex

all: $(BOOK).pdf

$(BOOK).pdf: $(SRC)
	latex $(BOOK).tex
	makeindex -o $(BOOK).ind $(BOOK).idx
	latex $(BOOK).tex
	dvipdfmx $(BOOK).dvi

clean:
	rm -f *.aux *.toc *.lon *.lor *.lof *.ilg *.idx *.ind *.out *.log *.exa

distclean: clean
	rm -f *.pdf *.dvi *~

	

