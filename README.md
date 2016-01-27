# dr
Docker Runner

# Use

Install a container supporting dr from DockerHub
```
dr install CONTAINERNAME
```

Manage that container
```
dr service COMMAND ARGS
```

For example:
```
dr install j842/simplesecrets
S3KEY=abcde S3SECRET=1234 BUCKET=mybucket dr simplesecrets configure
dr simplesecrets < myfile
```
