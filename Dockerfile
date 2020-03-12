FROM python:3.7

LABEL "repository"="https://github.com/sergioisidoro/github-transifex-action"
LABEL "homepage"="https://github.com/sergioisidoro/github-transifex-action"
LABEL "maintainer"="Sergio Isidoro <smaisidoro@gmail.com>"


RUN pip install transifex-client
RUN apt-get install git

ADD entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
