# SomeNA
**In short**: SomeNA serves for the prediction of protein DNA/RNA binding.    
**Authors**: [Peter Hoenigschmid](mailto:hoenigschmid@rostlab.org), [Burkhard Rost](rostlab.org)   
**Year**: 2012     
**Language**: Perl        
**Elixir**: https://bio.tools/tool/RostLab/SomeNA/1    
**Documentation**: https://github.com/Rostlab/someNA/tree/develop/documentation

## Installation

### Basic Installation

**Requirements**:       

  - [autoconf](http://www.gnu.org/software/autoconf/autoconf.html)
  - [make](https://www.gnu.org/software/make/)
  - [libfann2](https://launchpad.net/ubuntu/trusty/+package/libfann2)
  - [libfann-dev](https://packages.debian.org/wheezy/libfann-dev)
  - [devscripts](https://packages.debian.org/unstable/devscripts)
  - [debhelper](https://packages.debian.org/sid/debhelper)
  - [AI::FANN](http://search.cpan.org/~salva/AI-FANN/lib/AI/FANN.pm)

**Installation**:     

  1. It is necessary to have all required packaged (listed above) installed before proceeding with the installation.
  In Debian-based distributions, these are easily obtainable via `apt`. To do so, type the following in a terminal window:

  ```
  apt-get update
  apt-get install -y autoconf make libfann2 libfann-dev devscripts debhelper
  ```

  AI::FANN cannot be installed via `atp`, but by typing `cpan AI::FANN` in the terminal, you should be good to go.     


  2. The easiest way of installing this software is by cloning this repository, going into the directory where this data is stored via the terminal (`cd`), launching `./pack.sh` (which will create a bundle for the installation, **note** Sometimes this can throw a `debsign: gpg error occurred!  Aborting....` but this will not influence the installation process) and then, from the same directory, type `make install` or `sudo make install` (depending on the distribution and user access).   

For more advanced instructions see [manual installation](https://github.com/Rostlab/someNA/wiki/Manual-Installation)

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
  4. Call SomeNA using `somena -i`, or if you used docker `docker start somena && docker attach somena`, then `somena -i /shared`.

Notice that somena could complain about some files missing, similarly as described in [this issue](https://github.com/Rostlab/someNA/issues/11). This most likely depends on the fact that the prediction optained in point 1 is not up to date and not all predictions on that sequence have been performed.    
In PredictProtein you actually have the possibility to resubmit a job. Please do so and test with the newly obtained prediction before opening a new issue.
