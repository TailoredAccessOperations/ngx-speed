#!/bin/bash

set -euo pipefail

# Set default values if not provided - Export so that child process can use env
: "${NGINX_PAGESPEED:=off}"
export NGINX_PAGESPEED

: "${NGINX_PAGESPEED_IMG:=off}"
export NGINX_PAGESPEED_IMG

: "${NGINX_PAGESPEED_JS:=off}"
export NGINX_PAGESPEED_JS

: "${NGINX_PAGESPEED_CSS:=off}"
export NGINX_PAGESPEED_CSS

: "${NGINX_PAGESPEED_STORAGE:=files}"
export NGINX_PAGESPEED_STORAGE

echo "env: NGINX_PAGESPEED: [${NGINX_PAGESPEED}]"
echo "env: NGINX_PAGESPEED_IMG image optimization: [${NGINX_PAGESPEED_IMG}]"
echo "env: NGINX_PAGESPEED_JS javascript optimization: [${NGINX_PAGESPEED_JS}]"
echo "env: NGINX_PAGESPEED_CSS stylesheets optimization: [${NGINX_PAGESPEED_CSS}]"
echo "env: NGINX_PAGESPEED_STORAGE: [${NGINX_PAGESPEED_STORAGE}]"


# Configure PageSpeed
if [ "${NGINX_PAGESPEED}" = "on" ]; then
  sed -i 's/pagespeed off;/pagespeed on;/g' /etc/nginx/conf.d/pagespeed.conf /etc/nginx/include/pagespeed.conf
else
  sed -i 's/pagespeed on;/pagespeed off;/g' /etc/nginx/conf.d/pagespeed.conf /etc/nginx/include/pagespeed.conf
fi

# Configure PageSpeed image processing
if [ "${NGINX_PAGESPEED_IMG}" = "on" ]; then
    sed -i 's/DisableFilters/EnableFilters/g' /etc/nginx/conf.d/pagespeed-image.conf
else
    sed -i 's/EnableFilters/DisableFilters/g' /etc/nginx/conf.d/pagespeed-image.conf
fi

# Configure PageSpeed javascript processing
if [ "${NGINX_PAGESPEED_JS}" = "on" ]; then
    sed -i 's/DisableFilters/EnableFilters/g' /etc/nginx/conf.d/pagespeed-js.conf
else
    sed -i 's/EnableFilters/DisableFilters/g' /etc/nginx/conf.d/pagespeed-js.conf
fi


# Configure PageSpeed css processing
if [ "${NGINX_PAGESPEED_CSS}" = "on" ]; then
    sed -i 's/DisableFilters/EnableFilters/g' /etc/nginx/conf.d/pagespeed-css.conf
else
    sed -i 's/EnableFilters/DisableFilters/g' /etc/nginx/conf.d/pagespeed-css.conf
fi

# Configure PageSpeed cache backend
if [ "${NGINX_PAGESPEED_STORAGE}" = "redis" ]; then
    if [ -z "${NGINX_PAGESPEED_REDIS+x}" ]; then
        echo "env: NGINX_PAGESPEED_STORAGE: [${NGINX_PAGESPEED_STORAGE}], but NGINX_PAGESPEED_REDIS not set"
        rm -f /etc/nginx/conf.d/pagespeed-redis.conf
    else
        echo "env: NGINX_PAGESPEED_REDIS: [${NGINX_PAGESPEED_REDIS}]"
        cat << EOF > /etc/nginx/conf.d/pagespeed-redis.conf
# redis storage backend
pagespeed RedisServer "${NGINX_PAGESPEED_REDIS}";
pagespeed RedisTimeoutUs 1000;
EOF
    fi
elif [ "${NGINX_PAGESPEED_STORAGE}" = "memcached" ]; then
    if [ -z "${NGINX_PAGESPEED_MEMCACHED+x}" ]; then
      echo "env: NGINX_PAGESPEED_STORAGE: [${NGINX_PAGESPEED_STORAGE}], but NGINX_PAGESPEED_MEMCACHED not set"
      rm -f /etc/nginx/conf.d/pagespeed-memcached.conf
    else
      echo "env: NGINX_PAGESPEED_MEMCACHED: [${NGINX_PAGESPEED_MEMCACHED}]"
      cat << EOF > /etc/nginx/conf.d/pagespeed-memcached.conf
# memcached storage backend
pagespeed MemcachedThreads 1;
pagespeed MemcachedServers "${NGINX_PAGESPEED_MEMCACHED}";
EOF
    fi

fi


# Remove default server configuration if requested
if [ "${NGINX_DEFAULT_SERVER}" = "off" ]; then
    echo "env: NGINX_DEFAULT_SERVER: [${NGINX_DEFAULT_SERVER}] - removing default server configuration"
    rm -f /etc/nginx/conf.d/default.conf
fi

# Add custom nginx config include path
if [ -z "${NGINX_INCLUDE_PATH+x}" ] || [ -z "${NGINX_INCLUDE_PATH}" ]; then
  echo "env: NGINX_INCLUDE_PATH not specified: [ SKIP ]"
else
    echo "env: NGINX_INCLUDE_PATH: [${NGINX_INCLUDE_PATH}]"
    sed -i 's/include \/etc\/nginx\/conf\.d\/\*\.conf;//\n    include '${NGINX_INCLUDE_PATH}'; # include custom configurations/g' /etc/nginx/nginx.conf

    for f in ${NGINX_INCLUDE_PATH}; do
        echo "conf: $f"
    done
fi