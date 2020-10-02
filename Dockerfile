FROM alpine:3.12

LABEL description="Simple forum software for building great communities" \
  maintainer="Hardware <hardware@mondedie.fr>, Magicalex <magicalex@mondedie.fr>"

ARG VERSION=v0.1.0-beta.13

ENV GID=991 \
  UID=991 \
  UPLOAD_MAX_SIZE=50M \
  PHP_MEMORY_LIMIT=128M \
  OPCACHE_MEMORY_LIMIT=128 \
  DB_HOST=localhost \
  DB_USER=flarum \
  DB_NAME=flarum \
  DB_PORT=3306 \
  FLARUM_TITLE=Docker-Flarum \
  DEBUG=false \
  LOG_TO_STDOUT=false \
  GITHUB_TOKEN_AUTH=false \
  PORT=8888

RUN apk add --no-progress --no-cache \
  curl \
  git \
  libcap \
  nginx \
  php7 \
  php7-ctype \
  php7-curl \
  php7-dom \
  php7-exif \
  php7-fileinfo \
  php7-fpm \
  php7-gd \
  php7-gmp \
  php7-iconv \
  php7-intl \
  php7-json \
  php7-mbstring \
  php7-mysqlnd \
  php7-opcache \
  php7-openssl \
  php7-pdo \
  php7-pdo_mysql \
  php7-phar \
  php7-session \
  php7-tokenizer \
  php7-xmlwriter \
  php7-zip \
  php7-zlib \
  su-exec \
  s6 \
  && cd /tmp \
  && curl -s http://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
  && chmod +x /usr/local/bin/composer \
  && composer global require --no-progress --no-suggest -- hirak/prestissimo \
  && mkdir -p /flarum/app \
  && COMPOSER_CACHE_DIR="/tmp" composer create-project --stability=beta --no-progress -- flarum/flarum /flarum/app $VERSION \
  && composer clear-cache \
  && rm -rf /flarum/.composer /tmp/* \
  && setcap CAP_NET_BIND_SERVICE=+eip /usr/sbin/nginx

RUN wget https://dl.google.com/cloudsql/cloud_sql_proxy.linux.amd64 -O /tmp/cloud_sql_proxy
RUN install /tmp/cloud_sql_proxy /usr/local/bin

COPY rootfs /
RUN chmod +x /usr/local/bin/* /services/*/run /services/.s6-svscan/*
VOLUME /flarum/app/extensions /etc/nginx/conf.d
CMD ["/usr/local/bin/startup"]
