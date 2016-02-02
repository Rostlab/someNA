# SomeNA
**In short**: SomeNA serves for the prediction of protein DNA/RNA binding.    
**Authors**: [Peter Hoenigschmid](mailto:hoenigschmid@rostlab.org), [Burkhard Rost](rostlab.org)     
**Elixir**: https://bio.tools/tool/RostLab/SomeNA/1    

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

Installation:    

It is necessary to have all required packaged (listed above) installed. In Debian-based distributions, these are easily obtainable via `apt`, with the exception of AI::FANN which can be installed by typing `cpan AI::FANN`.    
The easiest way of installing this software is by cloning this repository, going into the directory where this data is stored via the terminal (`cd`), launching `./pack.sh` (which will create a bundle for the installation) and then, from the same directory, type `make install` or `sudo make install` (depending on the distribution and user access).   

For more advanced instructions see [advanced installation](https://github.com/Rostlab/someNA/wiki/Manual-Installation)

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

#### Build image
To build the docker image from scratch:
  1.  Download this repo, `cd` into it
  2.  `docker build somena`
  3.  `docker images`
  4.  `docker run -it -d -P --name somena -v /path/to/local/folder:/docker rostlab/somena bash`
  5.  See above.
  

### Examples

If you want to test the software you can do the following:
  1. Select a sequence of your choice and use [PredictProtein](http://ppopen.informatik.tu-muenchen.de/) to generete all the files necessary to SomeNA to operate correctly.
  2. Once you submit your sequence to PredictProtein and get some result back, download all results (export on the top left, and export all data files).
  3. Unizip the file you just downloaded and:     
        -   If you have SomeNA installed on your OS: `cd` into the directory with the unzipped files.     
        -   If you are using Docker, copy the content of your folder into the shared folder (See the second last slide of [this presentation](https://github.com/Rostlab/someNA/blob/develop/documentation/Sprint_1.pdf)).
  4. Call SomeNA using `somena -i`, or if you used docker `docker start somena && docker attach somena`, then `somena -i /shared`

Copyright:
Copyright 2011 by Peter Hoenigschmid, Technical University Munich (Munich, DE)
Copyright 2011 by Burkhard Rost, Technical University Munich (Munich, DE)
