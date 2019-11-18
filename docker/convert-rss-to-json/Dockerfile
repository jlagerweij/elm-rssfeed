FROM debian:buster-slim

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install --no-install-recommends -y \
  php-cli \
  php-simplexml \
  ca-certificates \
  inetutils-ping \
  curl \
  cron \
  && rm -rf /var/lib/apt/lists/*

COPY docker-entrypoint.sh /
COPY docker-entrypoint.d/* /docker-entrypoint.d/

COPY convert-rss-to-json-cron /etc/cron.d/convert-rss-to-json-cron
RUN chmod 0644 /etc/cron.d/convert-rss-to-json-cron
RUN crontab /etc/cron.d/convert-rss-to-json-cron
RUN touch /var/log/cron.log

COPY convert-rss-to-json.php /app/

ENTRYPOINT ["/docker-entrypoint.sh", "cron"]
CMD ["-f"]