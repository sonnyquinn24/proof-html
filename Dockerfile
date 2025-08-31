FROM alpine:3.22 AS base

RUN apk --no-cache add openjdk21

FROM base AS build-vnu

RUN apk add git python3

RUN git clone -n https://github.com/validator/validator.git \
    && cd validator \
    && git checkout 84a1b28ff4cc28b7e9a31784688dbee6366b3467 \
    && JAVA_HOME=/usr/lib/jvm/java-21-openjdk python checker.py update-shallow dldeps build jar

FROM base

RUN apk --no-cache add build-base linux-headers ruby-dev
RUN apk --no-cache add curl
RUN gem install html-proofer -v 5.0.10

RUN apk --no-cache add bash

COPY --from=build-vnu /validator/build/dist/vnu.jar /bin/vnu.jar

COPY entrypoint.sh proof-html.rb /

ENTRYPOINT ["/entrypoint.sh"]
