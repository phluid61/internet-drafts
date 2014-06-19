
# Create a new draft
# Usage: make [draft-short-name]
#
# Copied from https://githu.com/mnot/I-D/

%::
	cp -a Tools/skel $@
	mv $@/draft-kerwin--00.xml $@/draft-kerwin-$@-00.xml
	sed -i -e"s/draft-kerwin--00/draft-kerwin-$@-00/" $@/draft-kerwin-$@-00.xml

