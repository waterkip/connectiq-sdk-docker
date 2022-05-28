Containerized ConnectIQ Development Environment for Linux
==

This is a repository were we build and maintain a development environment where
you can use Garmin SDK's on Linux. Because the Linux SDK (manager) uses
completely outdated software[^1][^2] this Docker development environment uses
Ubuntu Bionic to satisfy its dependencies.

## EULA of Garmin

This project DOES NOT distribute the SDK or the SDK manager, you therefore are
not in violation of the Garmin EULA.

## .Garmin/ConnectIQ

Please make sure you create the following directory in your $HOME.

```
mkdir -p $HOME/.Garmin/ConnectIQ
```

## Building

You can run `./build` to trigger a docker build.

## docker-compose

This project can also build the image via docker-compose, simply run
`docker-compose build`. It will also check if all the files have a correct
license.

In `docker-compose.example-project` you'll find an example docker-compose.yml
file which you can use in your ConnectIQ project.

## SDK manager

You can start the SDK manager by typing `sdkmanager`.

# Thank you

I want to thank [Cédric Dufour](https://github.com/cedric-dufour) for his
[Connect IQ docker work](https://github.com/cedric-dufour/connectiq-sdk-docker) which this
repository has used as a base.

# See also

[^1]: https://forums.garmin.com/developer/connect-iq/i/bug-reports/simulator-not-working-on-ubuntu-19-04
[^2]: https://forums.garmin.com/developer/connect-iq/i/bug-reports/upgrade-sdk-deps-so-modern-linux-distros-work

