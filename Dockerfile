FROM alpine:latest
LABEL MAINTAINER="Jonathan Harris <jonathan@marginal.org.uk>"
ENV GETIPLAYER_OUTPUT=/output GETIPLAYER_PROFILE=/output/.get_iplayer PUID=1000 PGID=100 PORT=1935 BASEURL=
EXPOSE $PORT
VOLUME "$GETIPLAYER_OUTPUT"

RUN set -eux; \
    \
    apk add --update --no-cache \
        ffmpeg \
        perl-cgi \
        perl-mojolicious \
        perl-lwp-protocol-https \
        perl-xml-libxml \
        jq \
        logrotate \
        su-exec \
        tini

RUN set -eux; \
    \
    apk add atomicparsley --repository http://dl-3.alpinelinux.org/alpine/edge/testing/ --allow-untrusted

RUN set eux; \
    \
    wget -qO - "https://api.github.com/repos/get-iplayer/get_iplayer/releases/latest" > /tmp/latest.json; \
    echo get_iplayer release `jq -r .name /tmp/latest.json`; \
    wget -qO - "`jq -r .tarball_url /tmp/latest.json`" | tar -zxf -; \
    cd get-iplayer*; \
    install -m 755 -t /usr/local/bin ./get_iplayer ./get_iplayer.cgi; \
    cd /; \
    rm -rf get-iplayer*; \
    rm /tmp/latest.json


# COPY files/ /

# ENTRYPOINT ["/sbin/tini", "--"]
# CMD /start
ENTRYPOINT ["get_iplayer", "--ffmpeg", "/usr/bin/ffmpeg", "--profile-dir", "$GETIPLAYER_PROFILE", "--output", "$GETIPLAYER_OUTPUT", "--atomicparsley", "/usr/bin/atomicparsley"]
CMD ["-h"]