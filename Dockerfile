# Development Docker image for BenchFoundry, with JDK, Maven & Thrift installed
# Allows running builds and tests, as well as executing Trace generators.
#
# To build Docker image run following command (in repository root):
#   docker build -t benchfoundrydev .
#
# To then build the BenchFoundry project and run tests, run the following command:
#   docker run --rm -v $(pwd):/usr/benchfoundry benchfoundrydev mvn clean generate-sources compile test assembly:single
#
# To then run (for example) the trace generator for the tpcc-inspired benchmark, the command would look like this:
#   docker run --rm -v $(pwd):/usr/benchfoundry benchfoundrydev java -cp /usr/benchfoundry/target/BenchFoundry-1.0-SNAPSHOT-jar-with-dependencies.jar de.tuberlin.ise.benchfoundry.tracegeneration.tpccinspiredbenchmark.TraceGenerator

FROM maven:3.6-jdk-8

# All the Thrift stuff knocked off from here: https://github.com/iGenius-Srl/docker-thrift-java/blob/master/Dockerfile
ENV THRIFT_VERSION 0.10.0

RUN buildDeps=" \
		automake \
		bison \
		curl \
		flex \
		g++ \
		libboost-dev \
		libboost-filesystem-dev \
		libboost-program-options-dev \
		libboost-system-dev \
		libboost-test-dev \
		libevent-dev \
		libssl-dev \
		libtool \
		make \
		pkg-config \
	"; \
	apt-get update && apt-get install -y --no-install-recommends $buildDeps && rm -rf /var/lib/apt/lists/* \
	&& curl -sSL "http://apache.mirrors.spacedump.net/thrift/$THRIFT_VERSION/thrift-$THRIFT_VERSION.tar.gz" -o thrift.tar.gz \
	&& mkdir -p /usr/src/thrift \
	&& tar zxf thrift.tar.gz -C /usr/src/thrift --strip-components=1 \
	&& rm thrift.tar.gz \
	&& cd /usr/src/thrift \
	&& ./configure  --without-python --without-cpp \
	&& make \
	&& make install \
	&& cd / \
	&& rm -rf /usr/src/thrift \
	&& curl -k -sSL "https://storage.googleapis.com/golang/go1.4.linux-amd64.tar.gz" -o go.tar.gz \
	&& tar xzf go.tar.gz \
	&& rm go.tar.gz \
	&& cp go/bin/gofmt /usr/bin/gofmt \
	&& rm -rf go \
	&& apt-get purge -y --auto-remove $buildDeps

# Configure the main working directory. This is the base
# directory used in any further RUN, COPY, and ENTRYPOINT
# commands.
RUN mkdir -p /usr/benchfoundry
WORKDIR /usr/benchfoundry

# Copy the main application.
COPY . /usr/benchfoundry

