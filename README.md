# dr
Docker Runner

# Basic Use

Configure dr's main directory for scripts. Only needs to be called once ever per host.
```
dr configure DIRECTORY
```

Install a container supporting dr from DockerHub
```
dr install CONTAINERNAME SERVICENAME
```

Manage that container
```
dr SERVICENAME COMMAND ARGS
```

## Example
Using [simplesecrets](https://github.com/j842/docker-simplesecrets) as the example:
```
dr configure /opt/dr
dr install j842/simplesecrets simplesecrets
dr simplesecrets help
S3KEY=abcde S3SECRET=1234 BUCKET=mybucket dr simplesecrets configure
dr simplesecrets < myfile
```

# Making a container compatible with dr

## Example

For an example see: https://github.com/j842/docker-dr-helloworld

## User

dr creates druser with uid 22022 and druser with gid 22022 on the host.
dr expects the Dockerfile to create that user and group and a USER command to switch to it.

## Files needed

The container image must include the drinstall script
```
/usr/local/bin/drinstall SERVICENAME IMAGE      -- populates /dr with everything below.
```

And drinstall neads to create the following:
```
/dr/txt/shorthelp.txt                           -- shown when dr is run with no args
/dr/bin/hostinit SERVICENAME IMAGE              -- automatically run on host when installed
/dr/bin/help SERVICENAME IMAGE                  -- show help for commands available
/dr/bin/run SERVICENAME IMAGE [ARGS...]         -- make the service go!
/dr/bin/ANOTHERCMD SERVICENAME IMAGE [ARGS...]  -- any other command needed.
```
Also create files in bin that can be run on the host to manage the container (e.g. configure).

## Files automatically added by dr available within the container

```
/dr/txt/containername.txt              -- e.g. j842/simplesecrets
/dr/txt/servicename.txt                -- e.g. simplesecrets
```