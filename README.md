# dr
Docker Runner

# Use

Configure dr's main directory for scripts (will ensure it's in the current user's path):
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

For example:
```
dr configure /opt/dr
dr install j842/simplesecrets simplesecrets
S3KEY=abcde S3SECRET=1234 BUCKET=mybucket dr simplesecrets configure
dr simplesecrets < myfile
```
