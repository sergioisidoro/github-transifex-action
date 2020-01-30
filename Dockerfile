FROM php:7.4-cli-alpine

LABEL "repository"="https://github.com/ergebnis/github-action-template"
LABEL "homepage"="https://github.com/ergebnis/github-action-template"
LABEL "maintainer"="Andreas Möller <am@localheinz.com>"

ADD entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
