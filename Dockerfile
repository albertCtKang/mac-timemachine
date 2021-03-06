FROM ubuntu:14.04.4
MAINTAINER Albert Kang <albertkang@gnap.com>

##################
##   BUILDING   ##
##################

# Prerequisites
RUN apt-get --quiet --yes update
ENV DEBIAN_FRONTEND noninteractive
RUN ln -s -f /bin/true /usr/bin/chfn

# Versions to use
ENV timemachine_path /timemachine
ENV libevent_version 2.0.22-stable
ENV netatalk_version 3.1.8
ENV dev_libraries libcrack2-dev libwrap0-dev autotools-dev libdb-dev libacl1-dev libdb5.3-dev libgcrypt11-dev libtdb-dev libkrb5-dev

# Install prerequisites:
RUN apt-get --quiet --yes install build-essential htop wget pkg-config checkinstall automake libtool db-util db5.3-util libgcrypt11 avahi-daemon avahi-utils ${dev_libraries}

# Compiling netatalk
WORKDIR /usr/local/src
RUN wget http://prdownloads.sourceforge.net/netatalk/netatalk-${netatalk_version}.tar.gz \
        && tar xvf netatalk-${netatalk_version}.tar.gz \
        && cd netatalk-${netatalk_version} \
        && ./configure \
                --enable-debian \
                --enable-krbV-uam \
                --disable-zeroconf \
                --enable-krbV-uam \
                --enable-tcp-wrappers \
                --with-cracklib \
                --with-acls \
                --with-dbus-sysconf-dir=/etc/dbus-1/system.d \
                --with-init-style=debian-sysv \
                --with-pam-confdir=/etc/pam.d \
        && make \
        && checkinstall \
                --pkgname=netatalk \
                --pkgversion=$netatalk_version \
                --backup=no \
                --deldoc=yes \
                --default \
                --fstrans=no \
        &&  apt-get --quiet --yes autoclean \
        &&  apt-get --quiet --yes autoremove \
        &&  apt-get --quiet --yes clean

# Add default user and group
RUN  mkdir -p ${timemachine_path}
# Add rwx privileges to group 
RUN  chmod 755 ${timemachine_path}

# Create the log file
RUN touch /var/log/afpd.log

ADD init_service.sh /usr/local/src/init_service.sh
ADD avahi/nsswitch.conf /etc/nsswitch.conf
ADD avahi/afpd.service /etc/avahi/services/afpd.service

RUN update-rc.d netatalk defaults

#EXPOSE 548

VOLUME ["${timemachine_path}"]

CMD [ "/bin/bash", "/usr/local/src/init_service.sh" ]


