LIBDIR := lib
include $(LIBDIR)/main.mk

$(LIBDIR)/main.mk:
	git clone -q --depth 10 -b main \
	    https://github.com/martinthomson/i-d-template $(LIBDIR)
