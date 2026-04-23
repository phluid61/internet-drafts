LIBDIR := lib
INDEX_FORMAT := md
-include $(LIBDIR)/main.mk

# Override the index.md rule to prepend Jekyll front matter and
# post-process the generated content:
#  - remove the first markdown heading (the theme layout provides it)
#  - replace the file-scheme "branch preview" with an archive link
$(GHPAGES_TARGET)/index.md: $(GHPAGES_INSTALLED) $(DEPS_FILES) | cleanup-ghpages
	printf -- '---\nlayout: default\n---\n' >$@
	$(LIBDIR)/build-index.sh md "$(dir $@)" "$(SOURCE_BRANCH)" "$(GITHUB_HOST)" "$(GITHUB_USER)" "$(GITHUB_REPO)" $(drafts_source) \
	  | sed '1{/^# /d;}' \
	  | sed '/^## Preview for branch \[file-scheme\]/,/^## /{/^## Preview for branch \[file-scheme\]/c\## Archive\n\n- [file-scheme](file-scheme/) — The file URI Scheme (RFC 8089)\n' -e '/^## /!d;}' \
	  >>$@

$(LIBDIR)/main.mk:
ifneq (,$(shell grep "path *= *$(LIBDIR)" .gitmodules 2>/dev/null))
	git submodule sync
	git submodule update --init
else
ifneq (,$(wildcard $(ID_TEMPLATE_HOME)))
	ln -s "$(ID_TEMPLATE_HOME)" $(LIBDIR)
else
	git clone -q --depth 10 -b main \
	    https://github.com/martinthomson/i-d-template $(LIBDIR)
endif
endif
