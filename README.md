Containerized ConnectIQ Development Environment for Linux
==

This is a repository were we build and maintain a development environment where
you can use Garmin SDK's on Linux.

## Why this project?

Because the Linux SDK (manager) uses completely outdated software[^1][^2] this
Docker development environment uses Ubuntu LTS to satisfy its dependencies. It
appears that Garmin uses Ubuntu LTS for to develop its SDK on which contains
some older software packages. For the SDK (manager) it seems that libjpeg.so.8
is required which cannot be found on other distro's than Ubuntu LTS. It would
be nice if Garmin starts using libjpeg9.

## Setting up your development environment

First start by making sure you have
[Docker](https://docs.docker.com/get-docker/) and
[docker-compose](https://docs.docker.com/compose/install/) installed on your
machine.

The next step is to create a developer key if you don't have one already:

```
./dev-bin/developer-key.sh
```

Now build the docker image:

```
./dev-bin/build.sh
```

You know have a docker image called `connectiq-sdk:latest`.

In `docker-compose.example-project` you'll find an example docker-compose.yml
file which you can use in your ConnectIQ project.

You can control your project with a very simple Makefile:

```
include /etc/garmin-connectiq/Makefile.ciq

MY_PROJECT := YourProject
```

You could add more variables in this Makefile or you add it to the
docker-compose.yml environment block:

```
MY_JUNGLES: /path/to/monkey.jungle # defaults to ${HOME}/src/monkey.jungle

CIQ_API: 3.2.6 # defaults to 1.0.0
CIQ_TYPECHECK: 0 # defaults to 2
CIQ_DEVKEY: /path/to/developer.der # defaults to ${HOME}/.Garmin/ConnectIQ/developer.der
CIT_FITFILE: /path/to/fitfile # defaults to ${HOME}/src/.session.fit

# used for make install and make uninstall
DESTDIR: /path/to/garmin-device/Garmin/Apps
```

If you running on a multi-user system and someone else has build the image,
please make sure that you tell docker-compose that you have the correct
UID/GID:

```
$ cat > .env <<OEF
CIQ_SDK_UID=$(id -u)
CIQ_SDK_GID=$(id -g)
OEF
```

Now you can run `docker-compose up --no-start` to create the container and
continue with `docker-compose run --rm connectiqi sdkmanager` to enter the
container and download the SDK and the devices you want to support with your
app.

After you have downloaded the SDK and the devices you can start developing.

Once you think you have enough code you can enter your container and issue
commands via `make`:

```
docker-compose run --rm connectiq
make
# This shows a help

# The following options are probably mostly used:

make test
make debug
make release
make run-debug
make run-release
make iq

# You can find out more information about the ciq devices you have by running:
make ciq-devices
```

## docker-compose

This project can also build the image via docker-compose, simply run
`docker-compose build`. Because this is mainly used for development it also
includes a reuse license check service.

# Thank you

I want to thank [Cédric Dufour](https://github.com/cedric-dufour) for his
[Connect IQ docker work](https://github.com/cedric-dufour/connectiq-sdk-docker) which this
repository has used as a base.

# LICENSE

This project uses Unlicense to respect the fork's license which was[^3]:

> All the stuff contained is this repository is entirely free and may be used,
> copied, modified, distributed and what-so-ever without any constraint.

The only difference is that this project feels that it cannot properly use the
Unlicense license for the Dockerfile itself. As Unlicense states that you can
redistribute the software as a compiled binary itself as well.

> Anyone is free to copy, modify, publish, use, compile, sell, or distribute
> this software, either in source code form or as a compiled binary, for any
> purpose,commercial or non-commercial, and by any means.

The project has the opinion that redistributing the Dockerfile in a binary form
is the actual Docker image and that includes software from Garmin. As there
isn't a FOSS license that excludes the binary form:

You cannot redistribute the resulting Docker image due to Garmin's EULA and its
closed source character.

## EULA of Garmin

This project DOES NOT distribute the SDK or the SDK manager, you therefore are
not in violation of the Garmin EULA.

# See also

[^1]: https://forums.garmin.com/developer/connect-iq/i/bug-reports/simulator-not-working-on-ubuntu-19-04
[^2]: https://forums.garmin.com/developer/connect-iq/i/bug-reports/upgrade-sdk-deps-so-modern-linux-distros-work
[^3]: https://github.com/cedric-dufour/connectiq-sdk-docker/blob/master/COPYRIGHT
