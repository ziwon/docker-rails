FROM ruby:2.4.3-alpine as builder
RUN apk update && apk add --no-cache \
    build-base \
    linux-headers \
    git \
    postgresql-dev \
    tzdata

WORKDIR /app
ADD Gemfile* /app/

# Always runs in production mode in a container environment,
# because livereload is not workingn properly
ENV RAILS_ENV production
ENV BUNDLER_VERSION 2.0.1

RUN gem update --system \
 && gem install bundler \
 && bundler update \
 && bundle install -j4 --retry 3 \
 && rm -rf /usr/local/bundle/cache/*.gem \
 && find /usr/local/bundle/gems/ -name "*.c" -delete \
 && find /usr/local/bundle/gems/ -name "*.o" -delete

ADD . /app


FROM ruby:2.4.3-alpine
RUN apk add --update --no-cache \
  git \
  postgresql-client \
  nodejs \
  jq \
  tzdata

ENV RAILS_ENV production
ENV BUNDLER_VERSION 2.0.1

ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8

RUN cp /usr/share/zoneinfo/Asia/Seoul /etc/localtime \
  && echo "Asia/Seoul" > /etc/timezone

RUN addgroup -g 1000 -S app \
  && adduser -u 1000 -S app -G app

USER app
COPY --from=builder /usr/local/bundle/ /usr/local/bundle/
COPY --from=builder --chown=app:app /app /app

WORKDIR /app
RUN date -u > BUILD_TIME
ENTRYPOINT ["/app/docker-entry.sh"]
CMD ["app"]
