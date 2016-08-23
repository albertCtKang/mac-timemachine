# docker-timemachine
A docker container to compile the lastest version of Netatalk in order to run a Time Machine server.

## Installation

To download the docker container and execute it, simply run:

`sudo docker run -h timemachine --name timemachine -e AFP_LOGIN=<YOUR_USER> -e AFP_PASSWORD=<YOUR_PASS> \
 -e AFP_NAME=<TIME_MACHINE_NAME> -e AFP_SIZE_LIMIT=<MAX_SIZE_IN_MB> -v /route/to/your/timemachine:/timemachine \
 -d -t -i --net=host vsdx/timemachine`

If you don't want to specify the maximum volume size (and use all the space available), you can omit the `-e AFP_SIZE_LIMIT=<MAX_SIZE_IN_MB>` variable.

Now you have a docker instance running `netatalk`.

## Auto-discovering

Afp daemon is commonly used to help your computers to find the services provided by a server, and only works if proiver network is the same with the client network. For spreading mDNS message to the client, Afp daemon is built into this Docker image. Remember that  --net=host is required if you would like the disk to show in Finder. If you don't need this, you can remove --net=host and connect in Finder with cmd+k -> afp://hostname/

Note that --net=host doesn't work with ubuntu trusty 14.04: https://github.com/docker/docker/issues/5899

The following steps show the regarding activities for running Avahi in the container (Ubuntu version):
* Install `avahi-daemon`: run `sudo apt-get install avahi-daemon avahi-utils`* Copy the file from `avahi/nsswitch.conf` to `/etc/nsswitch.conf`
* Copy the service description file from `avahi/afpd.service` to `/etc/avahi/services/afpd.service`
* Restart Avahi's daemon: `sudo /etc/init.d/avahi-daemon restart`

**Note:** In order to run Avahi in the container, please make sure dbus-daemon has been running.

* To start the service: `sudo /etc/init.d/dbus start`

## Start and Stop the timemachine service in the container

* To start the service: `sudo service timemachine start`
* To stop the service: `sudo service timemachine stop`

**Note:** when you stop the service, the container keeps running. Yo must execute `sudo docker stop timemachine`in order to stop the server.

## Modify netatalk's configuration files

If you want to modify the netatalk's configuration file, called `afp.conf`, you can do it cloning this repo, changing the contents in `init_service.sh` script and the re-build the image with `sudo docker build .`.

Also, you can change it by accessing the container and modifying it in live, but remember to save the changes like when the password was changed (see above).

