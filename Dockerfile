# from https://github.com/nacyot/elasticsearch
FROM n42corp/es-base:2.3.1

#-------------------------------------------------------------------------------
# Download and extract
#-------------------------------------------------------------------------------

WORKDIR /opt

RUN wget https://bitbucket.org/eunjeon/mecab-ko/downloads/mecab-0.996-ko-0.9.2.tar.gz \
    && tar xvf mecab-0.996-ko-0.9.2.tar.gz

RUN wget http://pkgs.fedoraproject.org/repo/pkgs/mecab-java/mecab-java-0.996.tar.gz/e50066ae2458a47b5fdc7e119ccd9fdd/mecab-java-0.996.tar.gz \
    && tar xvf mecab-java-0.996.tar.gz

RUN wget https://bitbucket.org/eunjeon/mecab-ko-dic/downloads/mecab-ko-dic-2.0.1-20150920.tar.gz \
    && tar xvf mecab-ko-dic-2.0.1-20150920.tar.gz

#-------------------------------------------------------------------------------
# Install build tools
#-------------------------------------------------------------------------------

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential \
        software-properties-common \
        automake \
        perl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

#-------------------------------------------------------------------------------
# Install mecab-ko
#-------------------------------------------------------------------------------

WORKDIR /opt/mecab-0.996-ko-0.9.2

RUN ./configure \
    && make \
    && make check \
    && make install \
    && ldconfig

WORKDIR /opt/mecab-java-0.996

RUN sed -i 's|/usr/lib/jvm/java-6-openjdk/include|/usr/lib/jvm/java-8-openjdk-amd64/include|' Makefile \
    && make \
    && cp libMeCab.so /usr/local/lib

#-------------------------------------------------------------------------------
# Install mecab korean dic
#-------------------------------------------------------------------------------

WORKDIR /opt/mecab-ko-dic-2.0.1-20150920

RUN ./autogen.sh \
    && ./configure \
    && make \
    && make install

#-------------------------------------------------------------------------------
# Install mecab-ko-analyzer(elasticsearch plugin)
#-------------------------------------------------------------------------------

RUN /usr/share/elasticsearch/bin/plugin install https://bitbucket.org/eunjeon/mecab-ko-lucene-analyzer/downloads/elasticsearch-analysis-mecab-ko-2.3.1.0.zip

#-------------------------------------------------------------------------------
# Install mecab-analyzer as an elasticsearch plugin
#-------------------------------------------------------------------------------

RUN /usr/share/elasticsearch/bin/plugin install mobz/elasticsearch-head --verbose \
    && /usr/share/elasticsearch/bin/plugin install polyfractal/elasticsearch-inquisitor --verbose

#-------------------------------------------------------------------------------
# Run Environment
#-------------------------------------------------------------------------------

ENV ES_JAVA_OPTS="-Des.security.manager.enabled=false -Djava.library.path=/usr/local/lib"

VOLUME ["/usr/share/elasticsearch/data"]