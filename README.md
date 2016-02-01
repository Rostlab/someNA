# SomeNA: protein DNA/RNA binding predictor

Copyright (C) 1994-1996, 1999-2002, 2004-2011 Free Software Foundation,
Inc.

Copying and distribution of this file, with or without modification,
are permitted in any medium without royalty provided the copyright
notice and this notice are preserved.  This file is offered as-is,
without warranty of any kind.

## Installation

### Basic Installation

Requirements:

  - [autoconf](http://www.gnu.org/software/autoconf/autoconf.html)
  - [make](https://www.gnu.org/software/make/)
  - [libfann2](https://launchpad.net/ubuntu/trusty/+package/libfann2)
  - [libfann-dev](https://packages.debian.org/wheezy/libfann-dev)
  - [devscripts](https://packages.debian.org/unstable/devscripts)
  - [debhelper](https://packages.debian.org/sid/debhelper)
  - [AI::FANN](http://search.cpan.org/~salva/AI-FANN/lib/AI/FANN.pm)

The simplest way to compile this package is:

  1. Install all the required packages. For Debian-based linux distributions, you can easily `apt-get` most of them.
      For the AI::FANN package, you can `cpan AI::FANN` to download and install it.

  2. `cd` to the directory containing the package's source code.
  
  3. Type `aclocal`, then `autoconf`, then `automake -a` and finally `automake` to generate the configuration files 
      specific to your system.

  4. You should now have a `configure` script in the root of the git directory.
      Type `./configure` to configure the package for your system.

     Running `configure` might take a while.  While running, it prints
     some messages telling which features it is checking for.

  5. Type `make` to compile the package.

  6. Optionally, type `make check` to run any self-tests that come with
     the package, generally using the just-built uninstalled binaries.

  7. Type `make dist`, to build the package for installation. This will create a .tar.gz file in the working directory.

  8. Type `debuild --lintian-opts --pedantic ` to bundle the package in a .deb file created in the home of your user.

  7. Type `make install` to install the programs and any data files and
     documentation.  When installing into a prefix owned by root, it is
     recommended that the package be configured and built as a regular
     user, and only the `make install` phase executed with root
     privileges, thus being `sudo make install`.

  8. Optionally, type `make installcheck` to repeat any self-tests, but
     this time using the binaries in their final installed location.
     This target does not install anything.  Running this target as a
     regular user, particularly if the prior `make install` required
     root privileges, verifies that the installation completed
     correctly.

To clean the created binaries or uninstall the tool:

  1. You can remove the program binaries and object files from the
     source code directory by typing `make clean`.  To also remove the
     files that `configure` created (so you can compile the package for
     a different kind of computer), type `make distclean`.  There is
     also a `make maintainer-clean` target, but that is intended mainly
     for the package's developers.  If you use it, you may have to get
     all sorts of other programs in order to regenerate files that came
     with the distribution.

  2. Often, you can also type `make uninstall` to remove the installed
     files again.  In practice, not all packages have tested that
     uninstallation works correctly, even though it is required by the
     GNU Coding Standards.

  3. Some packages, particularly those that use Automake, provide `make
     distcheck`, which can by used by developers to test that all other
     targets like `make install` and `make uninstall` work correctly.
     This target is generally not run by end users.

For more advanced instructions see [advanced installation](https://github.com/Rostlab/someNA/wiki/Advanced-Installation)

### Docker

If you want to run this application without the hustle of looking at dependencies, you can easily
pull an already existing image from docker hub or build the Dockerfile contained in this repo.

#### Pull image
To run the image on [docker hub](https://hub.docker.com/r/rostlab/somena) :
  1. `docker run -it -d -P --name somena -v /path/to/local/folder:/docker rostlab/somena bash`
      Where `/path/to/local/folder` is the folder containing the data needed to run someNA, and this
      data will be accessible in the docker instance at `/docker`.
      This command will automatically pull the image and start a bash process in it.
  2.  To later attach to the image type: `docker attach somena`
  3.  If the docker instance is not running, type `docker start somena`

#### Pull image
To build the docker image from scratch:
  1.  Download this repo, `cd` into it
  2.  `docker build somena`
  3.  `docker images`
  4.  `docker run -it -d -P --name somena -v /path/to/local/folder:/docker rostlab/somena bash`
  5.  See above.

## Authors

* [Peter Hoenigschmid](mailto:hoenigschmid@rostlab.org)
* Burkhard Rost

Copyright:
Copyright 2011 by Peter Hoenigschmid, Technical University Munich (Munich, DE)
Copyright 2011 by Burkhard Rost, Technical University Munich (Munich, DE)
