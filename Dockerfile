FROM --platform=$TARGETPLATFORM alpine AS runtime
ARG TARGETPLATFORM
ARG BUILDPLATFORM

MAINTAINER pstauffer@confirm.ch

#
# Install all required dependencies.
#

RUN set -eux; \
    \
    apk add --update --no-cache curl inotify-tools

#
# Add named init script.
#

ADD init.sh /init.sh
RUN chmod 750 /init.sh


#
# Define container settings.
#

WORKDIR /tmp


#
# Start named.
#

CMD ["/init.sh"]
