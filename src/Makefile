
SUBDIRS = ./chapter2/1 ./chapter2/2 ./chapter3/1 ./chapter3/2 ./chapter3/3 \
./chapter3/4 ./chapter3/5 ./chapter3/6 ./chapter3/7 ./chapter3/8


all:
	for dir in $(SUBDIRS); do \
		$(MAKE) -C $$dir; \
	done

copy:
	for dir in $(SUBDIRS); do \
		$(MAKE) -C $$dir copy; \
	done

clean:
	for dir in $(SUBDIRS); do \
		$(MAKE) -C $$dir clean; \
	done

distclean:
	for dir in $(SUBDIRS); do \
		$(MAKE) -C $$dir distclean; \
	done

release:
	for dir in $(SUBDIRS); do \
		$(MAKE) -C $$dir release; \
	done; \
	chown solrex `find -name "solrex.img"`
