# Staging: clone github repo and install
FROM            golang:1.17.5-alpine3.15 AS build

RUN             apk --update add git

WORKDIR         /tmp

RUN             git clone https://github.com/javgh/sia-nbdserver.git && \
                cd sia-nbdserver && \
                git branch remotes/origin/tcp && \
                go install



# Build final image
FROM            alpine:latest

COPY            --from=build /go/bin /

VOLUME          /data /cache

COPY            start.sh /

ENV             SIA_API_ADDRESS="127.0.0.1:9980"
ENV             SIA_PASSWORD_FILE="/data/apipassword"
ENV             SERVER_ADDRESS="127.0.0.1:10809"
ENV             XDG_DATA_HOME="/cache"

EXPOSE          10809/tcp

ENTRYPOINT      ["./start.sh"]
