# Under heavy development. Try it, don't use it.

# Docker Runner

Docker Runner (dr) is a script and a set of conventions to make it easy to install, 
configure and use Docker containers. 

Docker Runner eliminates the need to separately store and manage scripts to use the Docker container, 
or deal with long docker run commands.

Features:
* dr compatible Docker Images are self contained - everything dr needs is inside
* Simple discoverable commands for using compatible services (no manual needed)
* Flexible configuration for each service, stored in a Docker Volume container that's managed for you
* Services can consist of any number of containers
* Backup a service to a single file, trivially restore on another machine
* Destroying a service leaves the machine in a clean state, no cruft left
* Containers run as non-root user
* Trivial to install a service multiple times with different configurations (e.g. mulitple minecraft servers)
* Ansible friendly for automation (see [Exit Codes](https://github.com/j842/dr#exit-codes) below).

# Usage

## Example

### First time installation

Install dr on the host:
```
    wget https://raw.githubusercontent.com/j842/dr/master/dr ; chmod a+x dr ; mv dr /usr/local/bin
```

Configure dr:
```
    dr configure /opt/dr
```

If you don't have docker you can install it on Debian with:
```
   wget -nv -O /tmp/install_docker.sh https://raw.github.com/j842/scripts/master/install_docker.sh ; bash /tmp/install_docker.sh
```

Now you're ready to try things.

### Running some containers

#### Helloworld

Install and try the [helloworld](https://github.com/j842/docker-dr-helloworld) example:
```
    dr install j842/dr-helloworld helloworld
    helloworld run
```

#### SimpleSecrets

Install and configure [simplesecrets](https://github.com/j842/docker-simplesecrets):
```
    dr install j842/simplesecrets simplesecrets
    S3KEY=abcde S3SECRET=1234 BUCKET=mybucket simplesecrets configure
```
    
Store secrets in S3:
```
    simplesecrets store < myfile
    PASS=? simplesecrets retrieve NAME
```

## General Use

Configure sets up dr's main directory for storing services. Only needs to be called once per host:
```
    dr configure DIRECTORY
```

Install a container (e.g. from DockerHub) that supports dr and call the service 'SERVICENAME'.
```
    dr install IMAGENAME SERVICENAME
```

Manage that service:
```
    SERVICENAME COMMAND ARGS
```
The available COMMANDs depend on the service; they can be things like run and configure. You can get help on the service
which also lists the available COMMANDs with
```
    SERVICENAME
```

Other commands that work on all services:
```
dr backup SERVICENAME BACKUPFILE     -- backup
dr restore SERVICENAME BACKUPFILE    -- restore (destructive, no confirmation! always backup first)
dr update SERVICENAME                -- update service scripts from container (e.g. after docker pull)
dr destroy SERVICENAME               -- destroy service and ALL data! Leaves host in clean state.
```
   

# Docker Runner Compatibility

## Example

For an example see: https://github.com/j842/docker-dr-helloworld

## User

dr creates druser with uid 22022 and drgroup with gid 22022 on the host when install is run.
dr requires the Dockerfile to create that user and group and have a USER command to switch to it.

## Standard Configuration Volume

The container must expose /config as a Volume. A Docker volume container is always created by dr as
dr-SERVICENAME-config and mounted in /config with option:
```
-v "dr-${SERVICENAME}-config:/config" 
```
This option needs to be in any scripts in /dr/host that launch the container. It is automatically
included in backup and restore operations.

## Backup/Restore 
You can backup and restore services. The backup is generally fully self contained, so can be restored to a different host!
(There may be external resources needed by the service, but for many its got everything. See the specific container for what it supports.).

Backup and restore of the standard configuration volume is managed by dr, the backup/restore scripts in /dr/host handle any other volume containers needed.

## Files Required

The container image must include a path /dr containing the following scripts that can be run on the host:
```
/dr/install SERVICENAME IMAGE        -- automatically run on host when installed
/dr/destroy SERVICENAME IMAGE        -- automatically run on host when destroyed
/dr/help SERVICENAME IMAGE           -- show help for commands available
/dr/backup SERVICENAME IMAGE PATH    -- backup to files in PATH
/dr/restore SERVICENAME IMAGE PATH   -- restore from files in PATH
/dr/enter SERVICENAME IMAGE          -- get bash shell in container
```

### Additional commands

You can also add any other command that would be useful, e.g. run, configure etc.
```
/dr/ANOTHERCMD SERVICENAME IMAGE [ARGS...]  -- any other command needed.
```

Those commands are invoked from the host with
```
dr SERVICENAME ANOTHERCMD [ARGS...]
```

## Exit Codes

The convention for exit codes is:
* 0 for success,
* 1 for error and 
* 3 for no change 

This is to aid Ansible.