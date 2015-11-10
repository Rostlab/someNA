FROM debian:wheezy

ADD someNA /somena
WORKDIR /somena

RUN apt-get update -y
RUN apt-get install -y autoconf
RUN apt-get install -y make

RUN aclocal
RUN autoconf
RUN automake --add-missing

RUN ./configure
RUN make
RUN make check
RUN make install
RUN make installcheck