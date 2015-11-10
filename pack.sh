make clean
make distclean
svn-clean
aclocal
autoconf
automake -a
automake
./configure
#./configure --prefix=/var/tmp/kiening/SomeNA
make
make dist
mv somena-1.0.1-1.tar.gz ../somena_1.0.1.tar.gz 
debuild --lintian-opts --pedantic 
#make install
