# CURRENTLY UNDER DEVELOPMENT AND BROKEN! (30 Jan 2016)

# Docker Runner

Docker Runner (dr) is a script and a set of conventions to make it easy to install, 
configure and use Docker containers. 

Docker Runner eliminates the need to separately store and manage scripts to use the Docker container, 
or deal with long docker run commands.

With Docker Runner each docker image has the ability to configure the host appropriately, meaning that you can use
simple discoverable commands (no manual needed) to use any compatible service. This configuration is flexible, with
any options or custom service configuration persisted within a docker volume container for that service 
that can be managed for you. It also supports destroying the service, removing any stored data and configuration and
leaving the host clean.

You can trivially install one docker image as multiple different services with different configuration options, 
e.g. to run multiple minecraft servers on different ports.

Docker Runner tries to be Ansible friendly for automation (see [Exit Codes](https://github.com/j842/dr#exit-codes) below).

# Basic Use

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
    dr SERVICENAME COMMAND ARGS
```
The available COMMANDs depend on the service; they can be things like run and configure. You can get help on the service
which also lists the available COMMANDs with
```
    dr SERVICENAME
```

Destroy the service, including destroying all stored data, leaving the host in a clean state:
```
    dr destroy SERVICENAME
``` 

Other commands that work on all services:
```
dr backup SERVICENAME BACKUPFILE     -- backup
dr restore SERVICENAME BACKUPFILE    -- restore (destructive, no confirmation! always backup first)
dr shell SERVICENAME                 -- shell access to container
dr update SERVICENAME                -- update service scripts from container (e.g. after docker pull)
```
   


## Example

### First time installation

Install dr on the host:
```
    wget https://raw.githubusercontent.com/j842/dr/master/dr ; chmod a+x dr
    mv dr /usr/local/bin
```

Configure dr:
```
    dr configure /opt/dr
```

Now you're ready to try things.

### Running some containers

#### Helloworld

Install and try the [helloworld](https://github.com/j842/docker-dr-helloworld) example:
```
    dr install j842/dr-helloworld helloworld
    dr helloworld run
```

#### SimpleSecrets

Install and configure [simplesecrets](https://github.com/j842/docker-simplesecrets):
```
    dr install j842/simplesecrets simplesecrets
    dr simplesecrets help
    S3KEY=abcde S3SECRET=1234 BUCKET=mybucket dr simplesecrets configure
```
    
Store secrets in S3:
```
    dr simplesecrets < myfile
```



# Making a container compatible with dr

## Example

For an example see: https://github.com/j842/docker-dr-helloworld

## User

dr creates druser with uid 22022 and drgroup with gid 22022 on the host when install is run.
dr requires the Dockerfile to create that user and group and have a USER command to switch to it.

## Standard Configuration Volume

The container must expose /dr/config as a Volume. A Docker volume container is always created by dr as
SERVICENAME-dr-standardconfig and mounted in /dr/config. 

## Backup/Restore 
You can backup and restore services. The backup is generally fully self contained, so can be restored to a different host!
(There may be external resources needed by the service, but for many its got everything. See the specific container for what it supports.).

Backup and restore of the standard configuration volume is managed by dr, the backup/restore scripts in /dr/host handle any other volume containers needed.

## Files Required

The container image must include a path /dr containing:

```
/dr/txt/shorthelp.txt                           -- shown when dr is run with no args
```

and the following mandatory scripts that can be run on the host:
```
/dr/host/install SERVICENAME IMAGE        -- automatically run on host when installed
/dr/host/destroy SERVICENAME IMAGE        -- automatically run on host when destroyed
/dr/host/help SERVICENAME IMAGE           -- show help for commands available
/dr/host/backup SERVICENAME IMAGE PATH    -- backup to files in PATH
/dr/host/restore SERVICENAME IMAGE PATH   -- restore from files in PATH
```

### Additional commands

You can also add any other command that would be useful, e.g. run, configure etc.
```
/dr/host/ANOTHERCMD SERVICENAME IMAGE [ARGS...]  -- any other command needed.
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