dist_noinst_DATA = $(PACKAGE).spec $(PACKAGE).spec.in Build.PL.in
dist_noinst_SCRIPTS = 

SUBDIRS = examples scripts lib share

all-local: build-stamp

clean-local:
	if [ -e Build ]; then perl Build clean && rm -f Build build-stamp; fi

distclean-local:
	rm -rf _build MYMETA.yml $(PACKAGE).spec

build-stamp: Build.PL
	perl Build.PL installdirs=vendor && perl Build && touch build-stamp

#distclean-local:
#	rm -rf _build MYMETA.yml MANIFEST MANIFEST.SKIP.bak MANIFEST.SKIP

#build-stamp: Build.PL
#	perl Build.PL installdirs=vendor && perl Build manifest && perl Build && touch build-stamp

install-data-local:
	perl Build install destdir=$(DESTDIR) $(INSTALL_BASE_ARG) create_packlist=0

dist-hook:
	rm -rf `find '$(distdir)' -name .svn`
