# log2 makefile
# 2013-4-8 14:26
# by Ian D Brunton <iandbrunton at gmail dot com>


install: Log.pm IDB.pm
	install -D -m 755 -o root -g root Log.pm $(DESTDIR)/usr/lib/perl5/vendor_perl/
	install -D -m 755 -o root -g root IDB.pm $(DESTDIR)/usr/lib/perl5/vendor_perl/
