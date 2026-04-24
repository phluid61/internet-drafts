LIBDIR := lib
INDEX_FORMAT := md
-include $(LIBDIR)/main.mk

# Override the index.md rule to prepend Jekyll front matter and
# post-process the generated content:
#  - remove the first markdown heading (the theme layout provides it)
#  - trim table rows to five columns, removing the phantom sixth column
#    that build-index.sh declares in the header but never populates
#  - strip all "Preview for branch" sections (subdirectories on gh-pages
#    are archives, not branch previews)
#  - append an Archive section listing any subdirectories
$(GHPAGES_TARGET)/index.md: $(GHPAGES_INSTALLED) $(DEPS_FILES) | cleanup-ghpages
	printf -- '---\nlayout: default\n---\n' >$@
	$(LIBDIR)/build-index.sh md "$(dir $@)" "$(SOURCE_BRANCH)" "$(GITHUB_HOST)" "$(GITHUB_USER)" "$(GITHUB_REPO)" $(drafts_source) \
	  | sed '1{/^# /d;}' \
	  | sed -E '/^\|/ s/^(\|[^|]*\|[^|]*\|[^|]*\|[^|]*\|[^|]*)\|.*/\1|/' \
	  | sed '/^## Preview for branch /,$$d' \
	  >>$@
	@archives=$$(find $(GHPAGES_TARGET) -mindepth 1 -maxdepth 1 -type d \
	  ! -name '.*' ! -name '_*' -printf '%f\n' | sort); \
	if [ -n "$$archives" ]; then \
	  printf '\n## Archive\n\n' >>$@; \
	  for d in $$archives; do \
	    printf -- '- [%s](%s/)\n' "$$d" "$$d" >>$@; \
	  done; \
	fi

# Provide navigation data for gh-pages Jekyll builds.
# jekyll-remote-theme only copies _layouts, _includes, and _sass from the
# remote theme — not _data — so we fetch navigation.yml from the base site.
ifneq (,$(GHPAGES_TARGET))
GHPAGES_ALL += $(GHPAGES_TARGET)/_data/navigation.yml
$(GHPAGES_TARGET)/_data/navigation.yml: | $(GHPAGES_TARGET)
	@mkdir -p $(dir $@)
	curl -sLf https://raw.githubusercontent.com/phluid61/phluid61.github.io/master/_data/navigation.yml -o $@ || touch $@
endif

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
