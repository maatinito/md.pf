FROM ruby:alpine AS base

FROM base AS builder
RUN apk add --update --virtual build-dependencies \
        build-base \
        gcc \
        git \
        postgresql-dev \
        yarn
ENV INSTALL_PATH /app
RUN mkdir ${INSTALL_PATH}
COPY Gemfile ${INSTALL_PATH}/
COPY Gemfile.lock ${INSTALL_PATH}/
COPY package.json ${INSTALL_PATH}/
COPY yarn.lock ${INSTALL_PATH}/

WORKDIR ${INSTALL_PATH}
RUN bundle config --global frozen 1
RUN bundle install --deployment --without development test
RUN yarn install --production

FROM base
ENV APP_PATH /app
COPY --from=builder /app ${APP_PATH}

RUN apk add --no-cache --update tzdata libcurl postgresql-libs yarn
WORKDIR ${APP_PATH}
COPY . ${APP_PATH}/
RUN bundle install --deployment --without development test && \
    rm -fr .git && \
    yarn install --production

ENV RAILS_ENV="production"
ENV RAILS_SERVE_STATIC_FILES=true
ENV RAILS_LOG_TO_STDOUT=true
ENV APP_NAME="tps_local"
ENV APP_HOST="localhost:3000"
ENV SOURCE="tps_local"
ENV SECRET_KEY_BASE="05a2d479d8e412198dabd08ef0eee9d6e180f5cbb48661a35fd1cae287f0a93d40b5f1da08f06780d698bbd458a0ea97f730f83ee780de5d4e31f649a0130cf0"
ENV SIGNING_KEY="aef3153a9829fa4ba10acb02927ac855df6b92795b1ad265d654443c4b14a017"
ENV DB_DATABASE="tps"
ENV DB_HOST="localhost"
ENV DB_POOL=""
ENV DB_USERNAME="tps"
ENV DB_PASSWORD="tps"
ENV BASIC_AUTH_ENABLED="disabled"
ENV BASIC_AUTH_USERNAME=""
ENV BASIC_AUTH_PASSWORD=""
ENV FOG_OPENSTACK_TENANT=""
ENV FOG_OPENSTACK_API_KEY=""
ENV FOG_OPENSTACK_USERNAME=""
ENV FOG_OPENSTACK_AUTH_URL=""
ENV FOG_OPENSTACK_REGION=""
ENV FOG_DIRECTORY=""
ENV FOG_ENABLED=""
ENV CARRIERWAVE_CACHE_DIR="/tmp/tps-local-cache"
ENV CLEVER_CLOUD_ACCESS_KEY_ID=""
ENV CLEVER_CLOUD_SECRET_ACCESS_KEY=""
ENV CLEVER_CLOUD_BUCKET=""
ENV FC_PARTICULIER_ID=""
ENV FC_PARTICULIER_SECRET=""
ENV FC_PARTICULIER_BASE_URL=""
ENV GITHUB_CLIENT_ID=""
ENV GITHUB_CLIENT_SECRET=""
ENV HELPSCOUT_MAILBOX_ID=""
ENV HELPSCOUT_CLIENT_ID=""
ENV HELPSCOUT_CLIENT_SECRET=""
ENV HELPSCOUT_WEBHOOK_SECRET=""
ENV SENTRY_ENABLED="disabled"
ENV SENTRY_DSN_RAILS=""
ENV SENTRY_DSN_JS=""
ENV MAILTRAP_ENABLED="disabled"
ENV MAILTRAP_USERNAME=""
ENV MAILTRAP_PASSWORD=""
ENV MAILJET_API_KEY=""
ENV MAILJET_SECRET_KEY=""
ENV API_ENTREPRISE_KEY=""
ENV PIPEDRIVE_KEY=""
ENV SKYLIGHT_DISABLE_AGENT="true"
ENV SKYLIGHT_AUTHENTICATION_KEY=""
ENV LOGRAGE_ENABLED="disabled"
ENV LOCAL_STORAGE="storage"

RUN adduser -Dh ${APP_PATH} userapp && chown -R userapp:userapp ${APP_PATH}/
USER userapp

RUN mkdir ${LOCAL_STORAGE} && bundle exec rails assets:precompile

VOLUME ${CARRIERWAVE_CACHE_DIR}
VOLUME ${LOCAL_STORAGE}

EXPOSE 3000

ENTRYPOINT ["bundle", "exec"]
CMD ["rails", "server", "-b", "0.0.0.0"]

# git clone https://github.com/sipf/tps.git
# cd tps/
# Modify config/environments/production.rb with this parameters :
# config.force_ssl = false
# protocol: :http # everywhere
# config.active_storage.service = :local

# Add Dockerfile in this repository and build
# docker build -t sipf/tps:0.1.0 .

# docker run -p 5432:5432 -e POSTGRES_USER=tps -e POSTGRES_PASSWORD=tps -d postgres:9.6-alpine
# docker run --rm -e DB_HOST="192.168.1.45" sipf/tps:0.1.0 rails db:setup

# docker run -e DB_HOST="192.168.1.45" -e MAILTRAP_ENABLED="enabled" -e MAILTRAP_USERNAME="xxxxxxxx" -e MAILTRAP_PASSWORD="yyyyyyyy" -e APP_HOST="beta.demarches-simplifiees.gov.pf" -d sipf/tps:0.1.0 rails jobs:work
# docker run -e DB_HOST="192.168.1.45" -e MAILTRAP_ENABLED="enabled" -e MAILTRAP_USERNAME="xxxxxxxx" -e MAILTRAP_PASSWORD="yyyyyyyy" -e APP_HOST="beta.demarches-simplifiees.gov.pf" -d -p 80:3000 sipf/tps:0.1.0

# Modify your /etc/hosts file so beta.demarches-simplifiees.gov.pf match your host.
# Log to http://beta.demarches-simplifiees.gov.pf with your browser, it must works.
# login : test@exemple.fr
# password : "this is a very complicated password !"

# Add aditionnal administrator
# docker run --rm -e DB_HOST="192.168.1.45" sipf/tps:0.1.0 rake admin:list
# docker run --rm -e DB_HOST="192.168.1.45" sipf/tps:0.1.0 "rake admin:create_admin[leonard.tavae@informatique.gov.pf]"
# docker run --rm -e DB_HOST="192.168.1.45" sipf/tps:0.1.0 "rake admin:delete_admin[leonard.tavae@informatique.gov.pf]"

