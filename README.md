# Docker Runner

Docker Runner (dr) is a script and a set of conventions to make it easy to install, configure and use Docker containers. 

With Docker Runner each docker image has the ability to configure the host appropriately, meaning that you can use
simple discoverable commands (no manual needed) to use any compatible service. This configuration is flexible, with
any options or custom configuration persisted within a docker volume container that can be managed for you.

This eliminates the need to separately store and manage scripts to use the Docker container, or deal with long docker run commands.

Docker Runner tries to be Ansible friendly for automation.

# Basic Use

Configure dr's main directory for scripts. Only needs to be called once per host:
```
    dr configure DIRECTORY
```

Install a container supporting dr from DockerHub:
```
    dr install CONTAINERNAME SERVICENAME
```

Manage that container:
```
    dr SERVICENAME COMMAND ARGS
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
dr expects the Dockerfile to create that user and group and have a USER command to switch to it.

## Files Required

The container image must include the drinstall script
```
/usr/local/bin/drinstall SERVICENAME IMAGE      -- populates /dr with everything below.
```
When dr install is invoked on the host:
* the service's directory on the host is mapped to /dr in the container,
* the container is started and the drinstall script is run inside the container.

drinstall then neads to create the following help file:
```
/dr/txt/shorthelp.txt                           -- shown when dr is run with no args
```

and the following scripts that can be run on the host:
```
/dr/bin/hostinit SERVICENAME IMAGE              -- automatically run on host when installed
/dr/bin/help SERVICENAME IMAGE                  -- show help for commands available
/dr/bin/run SERVICENAME IMAGE [ARGS...]         -- run on the host to make the service go!
```

### Additional commands

You can also add any other comamnd that would be useful, e.g. a configuration command.
```
/dr/bin/ANOTHERCMD SERVICENAME IMAGE [ARGS...]  -- any other command needed.
```

Those commands are invoked from the host with
```
dr SERVICENAME ANOTHERCMD [ARGS...]
```

## Files automatically added by dr which are available within the container

```
/dr/txt/containername.txt              -- e.g. j842/simplesecrets
/dr/txt/servicename.txt                -- e.g. simplesecrets
```

## Exit Codes

The convention for exit codes is:
* 0 for success,
* 1 for error and 
* 3 for no change 

This is to aid Ansible.