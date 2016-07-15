FROM ovn-scale-test-base

# Install Skydive Analyzer

RUN apt-get update \
    && apt-get install -y openjdk-7-jre \
    && apt-get install wget
RUN wget https://download.elastic.co/elasticsearch/elasticsearch/elasticsearch-1.7.2.deb
RUN dpkg -i elasticsearch-1.7.2.deb
RUN update-rc.d elasticsearch defaults
# RUN service elasticsearch start

RUN mkdir -p $GOPATH/src/github.com/redhat-cip
RUN git clone https://github.com/sivakom/skydive.git $GOPATH/src/github.com/redhat-cip/skydive
RUN cd $GOPATH/src/github.com/redhat-cip \
    && godep save \
    && cd $GOPATH/src/github.com/redhat-cip/skydive \
    && make install
# RUN cd
# to change the config, can either use sed or clone a custom copy of skydive
# for now, will use my local fork.
# RUN $GOPATH/bin/skydive analyzer --conf $GOPATH/src/github.com/redhat-cip/skydive/etc/skydive.yml

# expose port for agents to talk to analyzer/elasticsearch
EXPOSE 8082
EXPOSE 9200
