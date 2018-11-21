FROM ruby:alpine AS base

#------------ intermediate container with specific dev tools
FROM base AS builder
RUN apk add --update --virtual build-dependencies \
        build-base \
        gcc \
        git \
        postgresql-dev \
        yarn
ENV INSTALL_PATH /app
RUN mkdir -p ${INSTALL_PATH}
COPY Gemfile Gemfile.lock package.json yarn.lock  ${INSTALL_PATH}/
WORKDIR ${INSTALL_PATH}
RUN bundle config --global frozen 1 &&\
    bundle install --deployment --without development test&&\
    yarn install --production

#----------- final tps
FROM base
ENV APP_PATH /app
RUN apk add --no-cache --update tzdata libcurl postgresql-libs yarn
WORKDIR ${APP_PATH}
RUN adduser -Dh ${APP_PATH} userapp
COPY --chown=userapp:userapp --from=builder /app ${APP_PATH}/
COPY --chown=userapp:userapp . ${APP_PATH}/
USER userapp
RUN bundle install --deployment --without development test && \
    rm -fr .git && \
    yarn install --production

ENV RAILS_ENV="production"\
	RAILS_SERVE_STATIC_FILES=true\
	RAILS_LOG_TO_STDOUT=true\
	APP_NAME="tps_local"\
	APP_HOST="localhost:3000"\
	SOURCE="tps_local"\
	SECRET_KEY_BASE="05a2d479d8e412198dabd08ef0eee9d6e180f5cbb48661a35fd1cae287f0a93d40b5f1da08f06780d698bbd458a0ea97f730f83ee780de5d4e31f649a0130cf0"\
	SIGNING_KEY="aef3153a9829fa4ba10acb02927ac855df6b92795b1ad265d654443c4b14a017"\
	DB_DATABASE="tps"\
	DB_HOST="localhost"\
	DB_POOL=""\
	DB_USERNAME="tps"\
	DB_PASSWORD="tps"\
	BASIC_AUTH_ENABLED="disabled"\
	BASIC_AUTH_USERNAME=""\
	BASIC_AUTH_PASSWORD=""\
	FOG_OPENSTACK_TENANT=""\
	FOG_OPENSTACK_API_KEY=""\
	FOG_OPENSTACK_USERNAME=""\
	FOG_OPENSTACK_AUTH_URL=""\
	FOG_OPENSTACK_REGION=""\
	FOG_DIRECTORY=""\
	FOG_ENABLED=""\
	CARRIERWAVE_CACHE_DIR="/tmp/tps-local-cache"\
	CLEVER_CLOUD_ACCESS_KEY_ID=""\
	CLEVER_CLOUD_SECRET_ACCESS_KEY=""\
	CLEVER_CLOUD_BUCKET=""\
	FC_PARTICULIER_ID=""\
	FC_PARTICULIER_SECRET=""\
	FC_PARTICULIER_BASE_URL=""\
	GITHUB_CLIENT_ID=""\
	GITHUB_CLIENT_SECRET=""\
	HELPSCOUT_MAILBOX_ID=""\
	HELPSCOUT_CLIENT_ID=""\
	HELPSCOUT_CLIENT_SECRET=""\
	HELPSCOUT_WEBHOOK_SECRET=""\
	SENTRY_ENABLED="disabled"\
	SENTRY_DSN_RAILS=""\
	SENTRY_DSN_JS=""\
	MAILTRAP_ENABLED="disabled"\
	MAILTRAP_USERNAME=""\
	MAILTRAP_PASSWORD=""\
	MAILJET_API_KEY=""\
	MAILJET_SECRET_KEY=""\
	API_ENTREPRISE_KEY=""\
	PIPEDRIVE_KEY=""\
	SKYLIGHT_DISABLE_AGENT="true"\
	SKYLIGHT_AUTHENTICATION_KEY=""\
	LOGRAGE_ENABLED="disabled"\
	LOCAL_STORAGE="storage"


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

