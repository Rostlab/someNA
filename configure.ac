AC_INIT([somena], [1.0.1-1], [hoenigschmid@rostlab.org])
AM_INIT_AUTOMAKE([-Wall])
AC_CONFIG_FILES([
                 Makefile
                 Build.PL
		 examples/Makefile
                 lib/Makefile
                 lib/RG/Makefile
                 lib/RG/SomeNA/Makefile
                 scripts/Makefile
                 share/Makefile
                 ])
AC_SUBST(INSTALL_BASE_ARG)

if test "x$prefix" != "x/usr"; then
    INSTALL_BASE_ARG=install_base=$prefix
fi

AC_OUTPUT
