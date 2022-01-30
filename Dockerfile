# Staging: clone github repo and install
FROM            golang:1.17.5-alpine3.15 AS build

RUN             apk --update add git

WORKDIR         /tmp

RUN             git clone https://github.com/javgh/sia-nbdserver.git && \
                cd sia-nbdserver && \
                git checkout remotes/origin/tcp && \
                go install


# Build final image
FROM            alpine:latest

COPY            --from=build /go/bin /

VOLUME          /data /cache

ENV             SIA_API_ADDRESS="127.0.0.1:9980"
ENV             SIA_PASSWORD_FILE="/data/apipassword"
ENV             PAGE_LIMIT_HARD="128"
ENV             PAGE_LIMIT_SOFT="96"
ENV             PAGE_IDLE="120"
ENV             DEV_SIZE="1099511627776"


ENV             XDG_DATA_HOME="/cache"

EXPOSE          10809/tcp

ENTRYPOINT      /sia-nbdserver \
                --sia-daemon $SIA_API_ADDRESS \
                --sia-password-file $SIA_PASSWORD_FILE \
                -u 0.0.0.0:10809 \
                -H $PAGE_LIMIT_HARD \
                -S $PAGE_LIMIT_SOFT \
                -i $PAGE_IDLE \
                -s $DEV_SIZE
