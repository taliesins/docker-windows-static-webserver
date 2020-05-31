# docker-windows-static-webserver

Small static file server for docker.

## Why

When building a Windows container there is not an easy way to prevent secrets from being leaked via history or in the layers. `--squash` is not supported with Windows containers and you can't mount a volume during a build with Windows containers either.

## Example

Setup web server that will serve secret file from the current directory.

### Create secret
```
$fileName = 'secrets.ps1'
$secrets=@"
`$env:password = 'P@ssw0rd'
"@
```

### Setup web server container
```
$containerName = 'file-server'
$port = '8080'
$directoryToServe = $pwd.Path.Replace("\", "/")

docker build -t webserver-image:v1 .
docker run  -v "$($directoryToServe):C:/site" --name $containerName -d -it -p 8080:$($port) webserver-image:v1
$ipAddress = docker inspect -f "{{ .NetworkSettings.Networks.nat.IPAddress }}" $containerName
$uri = "http://$($ipAddress):$($port)/$fileName"
Write-Host $uri
```

### Pass reference to web server container into another container
```
docker build --build-arg SECRET_URI="$uri"
```

### Download file in another container
```
curl -fSLo $fileName $uri
. $fileName
remove-item $fileName -force
```

### Clean up web server container
```
docker container rm $containerName -f
```
