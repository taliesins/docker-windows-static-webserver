FROM golang:nanoserver-1809 as gobuild

COPY . /code
WORKDIR /code

RUN go build webserver.go

FROM mcr.microsoft.com/windows/nanoserver:1809

COPY --from=gobuild /code/webserver.exe /webserver.exe

EXPOSE 8080

CMD ["\\webserver.exe"]