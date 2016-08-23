#!/bin/bash

set -e

if [ ! -e /.timemachine.ini ]; then
    if [ -z $AFP_LOGIN ]; then
        echo "no AFP_LOGIN specified!"
        exit 1
    fi

    if [ -z $AFP_PASSWORD ]; then
        echo "no AFP_PASSWORD specified!"
        exit 1
    fi

    if [ -z $AFP_NAME ]; then
        echo "no AFP_NAME specified!"
        exit 1
    fi

# Add the user
    useradd $AFP_LOGIN -M
    echo $AFP_LOGIN:$AFP_PASSWORD | chpasswd

    echo "[Global]
        log file = /var/log/afpd.log

[${AFP_NAME}]
        path = /timemachine
        time machine = yes
        valid users = ${AFP_LOGIN}" >> /usr/local/etc/afp.conf

    if [ -n "$AFP_SIZE_LIMIT" ]; then
        echo "
        vol size limit = ${AFP_SIZE_LIMIT}" >> /usr/local/etc/afp.conf
    fi

    touch /.timemachine.ini
fi

sed -Ei s/__AFP_NAME__/$AFP_NAME/g /etc/avahi/services/afpd.service

# Initiate the timemachine daemons
# The path of the timemachine must be synchornized with the assignment in Dockerfile
chown -R $AFP_LOGIN:$AFP_LOGIN /timemachine

# Clean out old locks
/bin/rm -f /var/lock/netatalk

# fixed dbus bug with wrong path of dbus-daemon configuring in /etc/init.d/dbus
if [ ! -f /usr/bin/dbus-daemon ]; then
    ln -sf /bin/dbus-daemon /usr/bin/dbus-daemon
fi

# Launch netatalk server
/etc/init.d/dbus start
/etc/init.d/avahi-daemon start
/etc/init.d/netatalk start

# wait indefinetely
while true
do
  tail -f /dev/null & wait ${!}
done

