FROM ovn-scale-test-base

# Used to specify a specific version of OVS to build with
ARG ovsrepo
ARG ovsbranch
ARG configflags

# Download OVS from git master
RUN echo "ovsrepo=$ovsrepo ovsbranch=$ovsbranch configflags=$configflags" \
    && git clone $ovsrepo \
    && cd /ovs \
    && git fetch $ovsrepo $ovsbranch \
    && git checkout FETCH_HEAD \
    && ./boot.sh \
    && ./configure $configflags \
    &&  make -j4 \
    &&  make install

COPY ovn-sandbox-database.sh /bin/ovn_set_database
RUN chmod 755 /bin/ovn_set_database

COPY ovn-sandbox-chassis.sh /bin/ovn_set_chassis
RUN chmod 755 /bin/ovn_set_chassis

COPY ovn-sandbox-north-ovsdb.sh /bin/ovn-sandbox-north-ovsdb.sh
COPY ovn-sandbox-south-ovsdb.sh /bin/ovn-sandbox-south-ovsdb.sh
COPY ovn-sandbox-northd.sh /bin/ovn-sandbox-northd.sh
RUN chmod 755 /bin/ovn-sandbox-north-ovsdb.sh \
              /bin/ovn-sandbox-south-ovsdb.sh \
              /bin/ovn-sandbox-northd.sh

# Install Skydive Agent

RUN mkdir -p $GOPATH/src/github.com/redhat-cip
RUN git clone https://github.com/sivakom/skydive.git $GOPATH/src/github.com/redhat-cip/skydive
RUN cd $GOPATH/src/github.com/redhat-cip \
    && godep save \
    && cd $GOPATH/src/github.com/redhat-cip/skydive \
    && make install
# RUN cd
# to change the config, can either use sed or clone a custom copy of skydive
# for now, will use my local fork.
# RUN $GOPATH/bin/skydive agent --conf $GOPATH/src/github.com/redhat-cip/skydive/etc/skydive.yml

# ENTRYPOINT ["/usr/local/bin/ovn_set_database"]
