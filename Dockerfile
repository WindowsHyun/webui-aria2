FROM debian:12-slim

# less priviledge user, the id should map the user the downloaded files belongs to
RUN groupadd -r dummy && useradd -r -g dummy dummy -u 1000

# webui + aria2
RUN apt-get update && \
    apt-get install -y aria2 busybox curl ca-certificates libc6 && \
    apt-get dist-upgrade -y && \
    rm -rf /var/lib/apt/lists/*

ADD ./docs /webui-aria2

# gosu install latest
RUN curl -L "https://github.com/tianon/gosu/releases/download/1.17/gosu-amd64" > /usr/local/bin/gosu  \
    && chmod +x /usr/local/bin/gosu

# goreman supervisor install latest
RUN curl -L "https://github.com/mattn/goreman/releases/download/v0.3.15/goreman_v0.3.15_linux_amd64.tar.gz" > goreman.tar.gz \
    && tar xvf goreman.tar.gz \
    && mv goreman_*/goreman /usr/local/bin/goreman \
    && rm -Rf goreman_*

# goreman setup
RUN echo "web: gosu dummy /bin/busybox httpd -f -p 8080 -h /webui-aria2\nbackend: gosu dummy /usr/bin/aria2c --enable-rpc --rpc-listen-all --dir=/data" > Procfile

# aria2 downloads directory
VOLUME /data

# aria2 RPC port, map as-is or reconfigure webui
EXPOSE 6800/tcp

# webui static content web server, map wherever is convenient
EXPOSE 8080/tcp

CMD ["start"]
ENTRYPOINT ["/usr/local/bin/goreman"]
