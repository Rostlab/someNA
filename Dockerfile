FROM debian:wheezy

ADD . /somena
WORKDIR /somena

RUN apt-get update -y
RUN apt-get install -y autoconf make libfann2 libfann-dev devscripts debhelper
RUN cpan AI::FANN
RUN ./pack.sh; exit 0
RUN make install
