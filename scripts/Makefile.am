dist_bin_SCRIPTS = somena
man1_MANS = somena.1

docdir = ${datadir}/doc/${PACKAGE}

somena.1: somena
	sed -e 's|__bindir__|$(bindir)|g;s|__datadir__|$(datadir)|g;s|__docdir__|$(docdir)|g;s|__pkgdatadir__|$(pkgdatadir)|g;s|__PREFIX__|$(prefix)|g;s|__sysconfdir__|$(sysconfdir)|g;s|__VERSION__|$(VERSION)|g;' "$<" | \
	pod2man -c 'User Commands' -r "$(VERSION)" -name $(shell echo "$(basename $@)" | tr '[:lower:]' '[:upper:]') > "$@"

install-exec-hook:
	sed -i -e 's|__bindir__|$(bindir)|g;s|__datadir__|$(datadir)|g;s|__docdir__|$(docdir)|g;s|__pkgdatadir__|$(pkgdatadir)|g;s|__PREFIX__|$(prefix)|g;s|__sysconfdir__|$(sysconfdir)|g;s|__VERSION__|$(VERSION)|g;' "$(DESTDIR)$(bindir)/somena"

install-data-hook:
	sed -i -e 's|__bindir__|$(bindir)|g;s|__datadir__|$(datadir)|g;s|__docdir__|$(docdir)|g;s|__pkgdatadir__|$(pkgdatadir)|g;s|__PREFIX__|$(prefix)|g;s|__sysconfdir__|$(sysconfdir)|g;s|__VERSION__|$(VERSION)|g;' "$(DESTDIR)$(man1dir)/somena.1"

clean-local:
	rm -f somena.1
