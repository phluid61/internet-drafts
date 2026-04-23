LIBDIR := lib
INDEX_FORMAT := md
-include $(LIBDIR)/main.mk

# Override the index.md rule to prepend Jekyll front matter,
# so that the remote theme layout is applied on gh-pages.
$(GHPAGES_TARGET)/index.md: $(GHPAGES_INSTALLED) $(DEPS_FILES) | cleanup-ghpages
	printf -- '---\nlayout: default\n---\n' >$@
	$(LIBDIR)/build-index.sh md "$(dir $@)" "$(SOURCE_BRANCH)" "$(GITHUB_HOST)" "$(GITHUB_USER)" "$(GITHUB_REPO)" $(drafts_source) >>$@

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
