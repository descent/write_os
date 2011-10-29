BOOK=WriteOS
SRC=WriteOS.tex solrexbook.sty utf8.cpx 000-cover.tex 000-preface.tex 000-foreword.tex 001.tex 002.tex 003.tex

WriteOS.pdf: WriteOS.ps
	ps2pdf $< 
WriteOS.ps:WriteOS.dvi
	dvips $<
WriteOS.dvi: $(SRC)
	latex $< && latex $<


clean:
	rm -f *.aux *.toc *.lon *.lor *.lof *.ilg *.idx *.ind *.out *.log *.exa *.dvi

distclean: clean
	rm -f *.pdf *.dvi *~ images
