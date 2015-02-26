##
##  Makefile -- Top-level build procedure for www.openssl.org
##

# Used to have a hack with a lockfile.
# Not needed since this is fast now.

SNAP=/var/cache/openssl/checkouts/openssl
PODSHOME=$(SNAP)/doc

FORCE=#-f
QUIET=--quiet

DIRS= about docs news source support

all: generated simple manpages

generated:
	cp -f $(SNAP)/LICENSE source/license.inc
	cp -f $(PODSHOME)/HOWTO/*.txt docs/HOWTO/.
	perl run-changelog.pl <$(SNAP)/CHANGES >news/changelog.inc
	perl run-faq.pl <$(SNAP)/FAQ >support/faq.inc
	perl run-fundingfaq.pl < support/funding/support-faq.txt >support/funding/support-faq.inc
	( cd news && xsltproc vulnerabilities.xsl vulnerabilities.xml > vulnerabilities.wml )

simple:
	wmk $(FORCE) -I $(SNAP) -a $(DIRS) index.wml

manpages:
	sh ./run-pod2html.sh $(PODSHOME)

# Update release notes (and other items, but relnotes is the use-case)
relupd:
	id | grep -q root || { echo you must sudo ; exit 1; }
	( cd $(SNAP)/.. ; for dir in openssl* ; do \
		echo Updating $$dir ; cd $$dir ; sudo -u openssl git pull $(QUIET) ; cd .. ; \
		done )
	sudo -u www-data git pull $(QUIET)
	sudo -u www-data $(MAKE) generated simple
