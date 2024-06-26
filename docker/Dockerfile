ARG TAG

################################################################################
# base image
#
# It's currently not easy to get Unison to run on Alpine. I'm using Debian, but
# other distributions could be used.
################################################################################
FROM --platform=linux/amd64 debian as base
RUN apt-get update && apt-get -y install ca-certificates

################################################################################
# download-ucm
#
# Fetches a ucm release and installs it to `/usr/local/bin/ucm`.
################################################################################
FROM --platform=linux/amd64 ${DOCKER_REPO}base:${TAG} as download-ucm

ADD https://github.com/unisonweb/unison/releases/download/release/0.5.20/ucm-linux.tar.gz /tmp/ucm-linux.tar.gz
RUN mkdir -p /opt/unisonlanguage && tar -x -z -f /tmp/ucm-linux.tar.gz -C /opt/unisonlanguage

################################################################################
# compile-unison-application
#
# Compiles the Unison program into a `.uc` file and stores it in `/usr/share/unisonapp/unisonapp.uc`.
################################################################################
FROM --platform=linux/amd64 ${DOCKER_REPO}base:${TAG} as compile-unison-application
RUN apt-get -y install gettext-base
COPY --from=download-ucm /opt/unisonlanguage/unison/unison /usr/local/bin/ucm
COPY pull-and-compile.md.tpl /tmp/
ARG SHARE_USER
ARG SHARE_NAMESPACE
ARG SHARE_PROJECT
ARG PROJECT_RELEASE
ARG MAIN_FUNCTION
RUN SHARE_USER="${SHARE_USER}" SHARE_PROJECT="${SHARE_PROJECT}" PROJECT_RELEASE="${PROJECT_RELEASE}" MAIN_FUNCTION="${MAIN_FUNCTION}" envsubst < /tmp/pull-and-compile.md.tpl > /tmp/pull-and-compile.md
RUN mkdir -p /usr/share/unisonapp
RUN /usr/local/bin/ucm transcript /tmp/pull-and-compile.md

################################################################################
# unison-application
#
# The main image that runs the Unison program.
################################################################################
FROM --platform=linux/amd64 ${DOCKER_REPO}base:${TAG} as unison-application
COPY --from=download-ucm /opt/unisonlanguage/unison/unison /usr/local/bin/ucm
COPY --from=compile-unison-application "/usr/share/unisonapp/unisonapp.uc" "/usr/share/unisonapp/unisonapp.uc" 

ENTRYPOINT ["/usr/local/bin/ucm", "run.compiled", "/usr/share/unisonapp/unisonapp.uc"]
CMD ["+RTS", "-N", "-qb", "-qn1"]
