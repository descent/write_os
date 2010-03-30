BOOKVER := 1.0-2-weekly

all: pdf 

.PHONY: pdf
pdf: ./pdf/
	make -C ./pdf/

.PHONY: src
src: ./src/
	make -C ./src/

copy: src
	make -C ./src/ copy

.PHONY: release
release: pdf/WriteOS.pdf
	mkdir -p release; \
	cp pdf/WriteOS.pdf release/writeos-$(BOOKVER).pdf; \
	make -C ./src/ release; \
	cp -r src release/writeos-$(BOOKVER); \
	cd release; \
	rm -rf `find  -name ".svn"`; \
	tar -czvf writeos-$(BOOKVER).tar.gz writeos-$(BOOKVER)

clean:
	make -C ./pdf
	make -C ./src
