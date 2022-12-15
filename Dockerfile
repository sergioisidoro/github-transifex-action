FROM alpine:3.17

LABEL "repository"="https://github.com/sergioisidoro/github-transifex-action"
LABEL "homepage"="https://github.com/sergioisidoro/github-transifex-action"
LABEL "maintainer"="Sergio Isidoro <smaisidoro@gmail.com>"

RUN apk add --no-cache bash curl git
RUN curl -o- https://raw.githubusercontent.com/transifex/cli/master/install.sh | bash
RUN mv tx /usr/bin/
RUN chmod +x /usr/bin/tx

ADD entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
