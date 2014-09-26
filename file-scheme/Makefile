
title = kerwin-$(shell basename "$(CURDIR)")
latest = $(shell (ls draft-$(title)-*.html || echo "draft-$(title)-00.xml") | sort | tail -1)
version = $(shell basename $(latest) .html | awk -F- "{print $$NF}")

master = $(shell echo $(CURDIR)| sed -e s/.gh-pages//)

.PHONY: all copy

all: copy index.html

index.html: $(latest)
	sed -e s/-$(version)/-latest/ $(latest) > index.html

copy:
	cp "$(master)/draft-$(title)-"* "$(CURDIR)/"

