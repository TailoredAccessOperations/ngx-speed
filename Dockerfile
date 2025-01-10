# Stage 1: Builder Stage
FROM debian:buster-slim AS builder

# Arguments passed at build time.
ARG MAKE_J=4
ARG NGINX_VERSION=1.25.3
ARG PAGESPEED_VERSION=1.13.35.2
ARG LIBPNG_VERSION=1.6.40
ARG VERSION
LABEL version=$VERSION

# Environment variables available during the build stage.
ENV MAKE_J=${MAKE_J} \
    NGINX_VERSION=${NGINX_VERSION} \
    LIBPNG_VERSION=${LIBPNG_VERSION} \
    PAGESPEED_VERSION=${PAGESPEED_VERSION} \
    DEBIAN_FRONTEND=noninteractive

# Set a DNS resolver.
RUN echo "nameserver 1.1.1.2" > /etc/resolv.conf

# Install only needed build dependencies in a single layer.
# Use --no-install-recommends to install only min deps and save space.
# && cleanup all apt related files to save space as soon as its not needed during the build.
# Install build dependencies
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
        git \
        g++ \
        gcc \
        curl \
        make \
        unzip \
        bzip2 \
        gperf \
        python3 \
        python3-dev \
        openssl \
        libuuid1 \
        pkg-config \
        icu-devtools \
        build-essential \
        ca-certificates \
        uuid-dev \
        zlib1g-dev \
        libicu-dev \
        libssl-dev \
        apache2-dev \
        libpcre3 \
        libpcre3-dev \
        libmaxminddb-dev \
        libpng-dev \
        libaprutil1-dev \
        libjpeg-turbo-dev \
        libcurl4-openssl-dev \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Build libpng
WORKDIR /tmp/build
RUN curl -L  "http://prdownloads.sourceforge.net/libpng/libpng-${LIBPNG_VERSION}.tar.gz" -o libpng.tar.gz && \
    tar -xzf libpng.tar.gz  && \
    cd "libpng-${LIBPNG_VERSION}" && \
    ./configure --build="$CBUILD" --host="$CHOST" --prefix=/usr --enable-shared --with-libpng-compat && \
    make -j${MAKE_J} install && \
    make install V=0

# Build PageSpeed
WORKDIR /tmp/build
RUN curl -L  "https://github.com/pagespeed/ngx_pagespeed/archive/v${PAGESPEED_VERSION}-stable.zip" -o pagespeed.zip && \
    unzip pagespeed.zip

WORKDIR  /tmp/build/incubator-pagespeed-ngx-${PAGESPEED_VERSION}-stable/
RUN psol_url=https://dl.google.com/dl/page-speed/psol/${PAGESPEED_VERSION}.tar.gz && \
    [ -e scripts/format_binary_url.sh ] && psol_url=$(scripts/format_binary_url.sh PSOL_BINARY_URL) && \
    echo "URL: ${psol_url}" && \
  curl -L  "${psol_url}" -o psol.tar.gz && tar -xzf psol.tar.gz

# Build additional Nginx modules in a single step
RUN git clone --depth 1 https://github.com/FRiCKLE/ngx_cache_purge.git && \
    git clone --depth 1 https://github.com/simplresty/ngx_devel_kit.git && \
    git clone --depth 1 https://github.com/openresty/echo-nginx-module.git && \
    git clone --depth 1 https://github.com/onnimonni/redis-nginx-module.git && \
    git clone --depth 1 https://github.com/openresty/redis2-nginx-module.git && \
    git clone --depth 1 https://github.com/openresty/srcache-nginx-module.git && \
    git clone --depth 1 https://github.com/openresty/set-misc-nginx-module.git && \
    git clone --depth 1 https://github.com/openresty/headers-more-nginx-module.git && \
    git clone --depth 1 https://github.com/google/ngx_brotli.git && \
    cd ngx_brotli/ && \
    git submodule update --init --recursive

# Build Nginx with GCC optimizations and custom modules
WORKDIR /tmp/build
RUN curl -L http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz -o nginx.tar.gz && \
    tar -xzf nginx.tar.gz  && \
    cd nginx-${NGINX_VERSION} && \
    export CFLAGS="-O3 -march=native -flto" && \
    export LDFLAGS="-s -Wl,--strip-all" && \
  LD_LIBRARY_PATH=/tmp/build/incubator-pagespeed-ngx-${PAGESPEED_VERSION}-stable/usr/lib:/usr/lib \
  ./configure \
        --sbin-path=/usr/sbin \
        --modules-path=/usr/lib/nginx \
        --with-http_ssl_module \
        --with-http_gzip_static_module \
        --with-file-aio \
        --with-http_v2_module \
        --with-http_realip_module \
        --with-http_sub_module \
        --with-http_gunzip_module \
        --with-http_secure_link_module \
        --with-http_stub_status_module \
        --with-threads \
        --with-stream \
        --with-stream_ssl_module \
        --without-http_autoindex_module \
        --without-http_browser_module \
        --without-http_userid_module \
        --without-mail_pop3_module \
        --without-mail_imap_module \
        --without-mail_smtp_module \
        --without-http_split_clients_module \
        --without-http_uwsgi_module \
        --without-http_scgi_module \
        --without-http_upstream_ip_hash_module \
        --prefix=/etc/nginx \
        --conf-path=/etc/nginx/nginx.conf \
        --http-log-path=/var/log/nginx/access.log \
        --error-log-path=/var/log/nginx/error.log \
        --pid-path=/var/run/nginx.pid \
		--add-module=/tmp/build/ngx_devel_kit \
        --add-module=/tmp/build/ngx_brotli \
        --add-module=/tmp/build/ngx_cache_purge \
        --add-module=/tmp/build/echo-nginx-module \
        --add-module=/tmp/build/redis-nginx-module \
        --add-module=/tmp/build/redis2-nginx-module \
        --add-module=/tmp/build/srcache-nginx-module \
        --add-module=/tmp/build/set-misc-nginx-module \
        --add-module=/tmp/build/headers-more-nginx-module \
        --add-module=/tmp/build/incubator-pagespeed-ngx-${PAGESPEED_VERSION}-stable && \
  make -j${MAKE_J} install --silent

#Build elfkickers to strip binaries.
WORKDIR /tmp
RUN curl -L "https://github.com/elfkickers/elfkickers/releases/download/1.1.0/elfkickers-1.1.0-linux.tar.gz" -o elfkickers.tar.gz && \
    tar -xzf elfkickers.tar.gz && \
    chmod +x /tmp/elfkickers/bin/strip



# Stage 2: Final Image
FROM debian:buster-slim

# Copy compiled Nginx and dependencies with --chown to avoid an extra layer
COPY --from=builder /usr/sbin/nginx /usr/sbin/nginx
COPY --from=builder /usr/lib/nginx /usr/lib/nginx
COPY --from=builder /etc/nginx /etc/nginx
COPY --from=builder /tmp/elfkickers/bin/strip /usr/bin/strip

# Install required system packages for runtime.
RUN apt-get update && apt-get install -y --no-install-recommends procps && rm -rf /var/lib/apt/lists/*

# Set a DNS resolver.
RUN echo "nameserver 1.1.1.2" > /etc/resolv.conf

# Create PageSpeed cache and set permissions. link log to stdout.
RUN  mkdir -p /var/cache/ngx_pagespeed && \
    chmod -R o+wr /var/cache/ngx_pagespeed && \
    ln -sf /dev/stdout /var/log/nginx/access.log && \
   ln -sf /dev/stderr /var/log/nginx/error.log

# Copy Nginx configurations
COPY ./config/conf.d              /etc/nginx/conf.d
COPY ./config/include             /etc/nginx/include
COPY ./config/nginx.conf          /etc/nginx/nginx.conf
COPY ./scripts                    /usr/local/bin/
COPY ./config/h5bp /etc/nginx/h5bp
COPY ./config/pagespeed /etc/nginx/pagespeed
COPY ./config/proxy /etc/nginx/proxy
COPY ./config/sites-enabled /etc/nginx/sites-enabled

#Strip nginx binary and modules
RUN /usr/bin/strip /usr/sbin/nginx && find /usr/lib/nginx -type f -exec /usr/bin/strip {} +

# install upx
RUN apt-get update && apt-get install -y upx && rm -rf /var/lib/apt/lists/*
#upx the nginx binary. This further reduces binary size but does make debugging harder.

RUN upx /usr/sbin/nginx

# set all executables as executable.
RUN chmod +x /usr/local/bin/*

# Expose ports
EXPOSE 80 8080

WORKDIR /etc/nginx
# Set up a health check. Use a port different then http to prevent direct access of a health check.
HEALTHCHECK --interval=5s --timeout=5s CMD curl -I http://127.0.0.1:8080/health || exit 1

# Entrypoint and command for container execution.
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]