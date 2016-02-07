## Under development. Try it, don't trust it!

# dRunner Compatiblity

See the [main documentation](https://github.com/j842/dRunner/blob/master/README.md) for information about dRunner itself.

The overhead of making a service dRunner compatible (above making a basic Docker image alone) is typically around 15 minutes to an
hour of work. What you get for that is a reusable, trivial to backup and restore component that you don't need to write a manual for and can easily be
managed and deployed by someone else (e.g. for putting into production with Ansible).

The key steps to make a dRunner compatible service are:
* configure /etc/drunner/config.sh to not pull on update, so it'll use local builds
* create new Dockerfile based on an existing image
* add the template scripts to /drunner in the image (see [helloworld](https://github.com/j842/drunner-helloworld) or [simplesecrets](https://github.com/j842/drunner-simplesecrets))
* modify them as needed
* check compatibility with drunner checkimage
* test functionality with the drunner/test service
* manually test
* share your image with the world

A typical workflow for developing is:
* build your docker image (docker build ...)
* install with drunner (drunner install ...)
* run it
* change your code or dockerfile
* rebuild the docker image (docker build ...)
* update the drunner install (drunner update ...)
* run it some more

dRunner respects image tags. It can pull from private repos if you're logged in.

## User

dr runs as root on the host.
dr requires the Dockerfile to create a non-root user and siwtch to it with the USER command. You
can set up and use sudo in the container, but you can't run as root (for security). Use different UIDs for
different services to help with container isolation.


## Required files

The container must include the files
```
/drunner/servicecfg.sh     -- define VOLUMES and EXTRACONTAINERS
/drunner/servicerunner     -- main script for managing hte service
```
servicecfg.sh is sourced by bash and defines an array of the paths to map as volume containers. It also
defines any additional containers that should be pulled on update (using the Docker Hub name).
See [helloworld](https://github.com/j842/dr-helloworld/blob/master/dr/servicecfg.sh) for an example.

See below for how to mount these containers when you run commands.


## Exit Codes

The convention for exit codes is:
* 0 for success,
* 1 for error and 
* 3 for no change 

This is to aid Ansible use.

## Security
See [Docker's Security Statement](https://docs.docker.com/engine/security/security) for information on security and docker.
There's a long way to go. For now, using sudo to run docker doesn't give you much over running as root - since with sudo you can
trivially map the host filesystem into a container and do whatever you want to it. Because of this, dRunner focuses
on security aspects that help, such as insisting containers are not run as root user. Avoid priveleged containers and
mapping the docker socket where possible and audit any scripts run on the host (dRunner makes this easy since they are all in one place).







# THE REST OF THIS IS OUTDATED AND WRONG! TO BE UPDATED


## Backup/Restore - WRONG
You can backup and restore services. The backup is generally self contained, so can be restored to a different host.
(There may be external resources needed by the service, but for many its got everything. See the specific container for what it supports.).

Backup and restore of the volumes defined by /drunner/volumes are managed by dRunner. The backup/restore scripts provided by the image
handle any other actions needed (such as dumping a database to a file).

## Files Required - WRONG

In additiont to /dr/volumes, the container image must include a path /drunner containing the following scripts that can be run on the host:
```
/drunner/install        -- automatically run on host when installed
/drunner/destroy        -- automatically run on host when destroyed
/drunner/help           -- show help for commands available
/drunner/backup  PATH   -- backup to files in PATH
/drunner/restore PATH   -- restore from files in PATH
/drunner/enter          -- get bash shell in container
```

Each of these bash scripts should begin by sourcing a variables.sh file in the same directory, i.e.
```
#!/bin/bash
source "$( dirname "$(readlink -f "$0")" )/variables.sh"
```

This file is created by dr when the service is installed and it sets several variables:
```
VOLUMES      Array of paths (as defined in the volumes file)
DOCKERVOLS   Array of the corresponding docker volume names
DOCKEROPTS   Array of the -v options to pass to docker to mount the volumes
SERVICENAME  Name of the service
IMAGENAME    Name of the docker image (e.g. j842/dr-helloworld)
INSTALLTIME  Datestamp for when the service was installed on the host
```

Using DOCKEROPTS, you can then run Docker like this from your /dr/ scripts:
```
docker run -i -t --name="mydocker" ${DOCKEROPTS[@]} ${IMAGENAME} echo "whee!"
docker rm "mydocker"
```

### Additional commands - WRONG

You can also add any other command (bash script) that would be useful, e.g. run, configure etc.
Also source variables.sh from these if you wish.
```
/drunner/ANOTHERCMD [ARGS...]  -- any other command needed.
```

Those commands are invoked from the host with
```
SERVICENAME ANOTHERCMD [ARGS...]
```
