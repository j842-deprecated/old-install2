# dr-support, a container to help Docker Runner do its thing.

FROM debian
MAINTAINER j842

# add in the support files.
COPY ["./support","/support"]
RUN echo "SUPPORTBUILDTIME=\"$(TZ=Pacific/Auckland date)\"" > /support/buildtime.sh 
RUN chown -R root:root /support && chmod 0555 -R /support

# don't run as root.
RUN groupadd -g 22055 drunnersupport
RUN adduser --disabled-password --gecos '' -u 22055 --gid 22055 drunnersupport
USER drunnersupport
