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
#  - append Contributor Code of Conduct and Licence sections
#  - sync content pages (code_of_conduct, CONTRIBUTING) to gh-pages
# Also fetches _data/navigation.yml from the base site and stages it,
# because jekyll-remote-theme only copies _layouts/_includes/_sass, not
# _data, so navigation must be provided explicitly.
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
	@printf '\n## Contributor Code of Conduct\n\n' >>$@
	@printf 'This repository is subject to a [Contributor Code of Conduct](code_of_conduct)\n' >>$@
	@printf 'adapted from the [Contributor Covenant](https://www.contributor-covenant.org),\n' >>$@
	@printf 'version 3.0, available at\n' >>$@
	@printf '<https://www.contributor-covenant.org/version/3/0/>\n' >>$@
	@printf '\n## Licence\n\n' >>$@
	@printf 'See the [guidelines for contributions](CONTRIBUTING).\n' >>$@
	@printf -- '---\nlayout: default\ntitle: "Contributor Code of Conduct"\npage_heading: "Contributor Covenant 3.0 Code of Conduct"\n---\n\n' \
	  >$(GHPAGES_TARGET)/code_of_conduct.md
	@sed '1{/^# /d;}' code_of_conduct.md >>$(GHPAGES_TARGET)/code_of_conduct.md
	@printf -- '---\nlayout: default\ntitle: "Contributing"\n---\n\n' \
	  >$(GHPAGES_TARGET)/CONTRIBUTING.md
	@sed '1{/^# /d;}' CONTRIBUTING.md >>$(GHPAGES_TARGET)/CONTRIBUTING.md
	@git -C $(GHPAGES_ROOT) add -f \
	  $(GHPAGES_TARGET)/code_of_conduct.md \
	  $(GHPAGES_TARGET)/CONTRIBUTING.md
	@mkdir -p $(GHPAGES_TARGET)/_data && \
	  (curl -sLf https://raw.githubusercontent.com/phluid61/phluid61.github.io/master/_data/navigation.yml \
	    -o $(GHPAGES_TARGET)/_data/navigation.yml || \
	    touch $(GHPAGES_TARGET)/_data/navigation.yml) && \
	  git -C $(GHPAGES_ROOT) add -f $(GHPAGES_TARGET)/_data/navigation.yml

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
