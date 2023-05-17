# The tag for the Docker images. This is used for cache invalidation, so it's important that it is
# unique per build.
ARG TAG

################################################################################
# base image
#
# It's currently not easy to get Unison to run on Alpine. I'm using Debian, but
# other distributions could be used.
################################################################################
FROM debian as base
RUN apt-get update && apt-get -y install ca-certificates

################################################################################
# download-ucm
#
# Fetches a ucm release and installs it to `/usr/local/bin/ucm`.
################################################################################
FROM ${DOCKER_REPO}base:${TAG} as download-ucm

ADD https://github.com/unisonweb/unison/releases/download/latest/ucm-linux.tar.gz /tmp/ucm-linux.tar.gz
RUN tar -x -z -f /tmp/ucm-linux.tar.gz -C /usr/local/bin ./ucm

################################################################################
# fetch-unison-application-hash
#
# Fetches the latest hash of the unison-application namespace and stores it in `/usr/share/unisonapp/hash.txt`.
# This is used to invalidate the docker cache if the namespace hash changes.
################################################################################
FROM ${DOCKER_REPO}base:${TAG} as fetch-unison-application-hash
RUN apt-get -y install curl jq
ARG SHARE_USER
ARG SHARE_NAMESPACE
ARG TAG
RUN mkdir -p "/usr/share/unisonapp"
RUN TAG="${TAG}" curl -f -s "https://api.unison-lang.org/codebases/${SHARE_USER}/browse?relativeTo=${SHARE_NAMESPACE}" | jq -r .namespaceListingHash > "/usr/share/unisonapp/hash.txt"

################################################################################
# compile-unison-application
#
# Compiles the Unison program into a `.uc` file and stores it in `/usr/share/unisonapp/unisonapp.uc`.
################################################################################
FROM ${DOCKER_REPO}base:${TAG} as compile-unison-application
RUN apt-get -y install gettext-base
COPY --from=download-ucm /usr/local/bin/ucm /usr/local/bin/ucm
COPY pull-and-compile.md.tpl /tmp/
ARG SHARE_USER
ARG SHARE_NAMESPACE
ARG MAIN_FUNCTION
RUN MAIN_FUNCTION="${MAIN_FUNCTION}" SHARE_USER="${SHARE_USER}" SHARE_NAMESPACE="${SHARE_NAMESPACE}" envsubst < /tmp/pull-and-compile.md.tpl > /tmp/pull-and-compile.md
RUN mkdir -p /usr/share/unisonapp
# If the namespace hash updates this will invalidate the docker cache so the pull command pulls the latest code.
# If it hasn't updated, we can just use the cached version.
COPY --from=fetch-unison-application-hash /usr/share/unisonapp/hash.txt /usr/share/unisonapp/hash.txt
RUN /usr/local/bin/ucm transcript /tmp/pull-and-compile.md

################################################################################
# unison-application
#
# The main image that runs the Unison program.
################################################################################
FROM ${DOCKER_REPO}base:${TAG} as unison-application
COPY --from=download-ucm /usr/local/bin/ucm /usr/local/bin/ucm
COPY --from=compile-unison-application "/usr/share/unisonapp/unisonapp.uc" "/usr/share/unisonapp/unisonapp.uc" 

ENTRYPOINT ["/usr/local/bin/ucm", "run.compiled", "/usr/share/unisonapp/unisonapp.uc"]
CMD ["+RTS", "-N", "-qb", "-qn1"]
