FROM elasticsearch:5.5

#-------------------------------------------------------------------------------
# Download Arirang
#-------------------------------------------------------------------------------

WORKDIR /opt

RUN wget http://jjeong.tistory.com/attachment/cfile4.uf@240DD74959630C7933BB16.zip

#-------------------------------------------------------------------------------
# Install mecab-ko-analyzer(Elasticsearch Plugin)
#-------------------------------------------------------------------------------

RUN /usr/share/elasticsearch/bin/elasticsearch-plugin install --verbose file:///opt/cfile4.uf@240DD74959630C7933BB16.zip

#-------------------------------------------------------------------------------
# Export Env Variables
#-------------------------------------------------------------------------------

ENV ES_JAVA_OPTS="-Des.security.manager.enabled=false -Djava.library.path=/usr/local/lib"

VOLUME ["/usr/share/elasticsearch/data"]