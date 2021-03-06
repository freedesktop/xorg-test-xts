SUBDIRS = src xts5
noinst_HEADERS = include

# Helper target to force generation of tetexec.cfg
.PHONY: tetexec.cfg
tetexec.cfg:
	@rm -f xts5/$@
	@cd xts5 && $(MAKE) $(AM_MAKEFLAGS) $@

# Helpers for running the test suite in-tree. Override the test set with
# scenario.
scenario =
run-tests: check.sh all
	@if test -z "$$DISPLAY"; then \
		echo "DISPLAY not set"; \
		exit 1; \
	fi
	$(SHELL) $(builddir)/check.sh $(scenario)
.PHONY: run-tests

# Helper target for testing subsets (test-Xopen, etc.)
test-%:
	@$(MAKE) $(AM_MAKEFLAGS) run-tests scenario='$*'

if HAVE_DOCTOOLS
miscmandir = $(MISC_MAN_DIR)
xtsman_txt = XTS.txt
xtsman_xml = $(xtsman_txt:.txt=.xml)
xtsman_pre = $(xtsman_txt:.txt=.man)
miscman_DATA = $(xtsman_pre:.man=.$(MISC_MAN_SUFFIX))

SUFFIXES = .man .$(MISC_MAN_SUFFIX) .txt .xml

XTS.txt: README
	cp $(srcdir)/README XTS.txt

.man.$(MISC_MAN_SUFFIX):
	sed -e 's|miscmansuffix|$(MISC_MAN_SUFFIX)|' < $< > $@
.txt.xml:
	$(ASCIIDOC) -b docbook -d manpage -o $@ $<
.xml.man:
	$(XMLTO) man $<
	mv -f $(@:.man=.miscmansuffix) $@

CLEANFILES = $(miscman_DATA) $(xtsman_xml) $(xtsman_pre) $(xtsman_txt)
endif

