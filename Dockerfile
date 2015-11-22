FROM debian:wheezy

ADD . /somena
WORKDIR /somena

RUN apt-get update -y
RUN apt-get install -y autoconf make libfann2 libfann-dev

RUN CC=gcc && export CC

RUN cpan AI::FANN

# RUN apt-get install -y autoconf make gcc git cmake build-essential
# RUN git clone https://github.com/libfann/fann.git
# WORKDIR /somena/fann
# RUN cmake .
# RUN make install

WORKDIR /somena
RUN aclocal
RUN autoconf
RUN automake --add-missing
RUN ./configure
RUN make
RUN make check
RUN make install
RUN make installcheck
