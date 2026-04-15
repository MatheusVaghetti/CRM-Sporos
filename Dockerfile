FROM node:23-alpine AS node
FROM ruby:3.4.4-alpine3.21 AS pre-builder

ARG PNPM_VERSION="10.2.0"
ENV PNPM_VERSION=${PNPM_VERSION}
ENV BUNDLE_WITHOUT="development:test"
ENV BUNDLER_VERSION=2.5.11
ENV RAILS_SERVE_STATIC_FILES=true
ENV RAILS_ENV=production
ENV NODE_OPTIONS="--max-old-space-size=4096 --openssl-legacy-provider"
ENV BUNDLE_PATH="/gems"
ENV PNPM_HOME="/root/.local/share/pnpm"
ENV PATH="$PNPM_HOME:$PATH"

RUN apk update && apk add --no-cache \
  openssl tar build-base tzdata postgresql-dev postgresql-client \
  git curl xz musl ruby-full ruby-dev gcc make musl-dev openssl-dev g++ \
  linux-headers vips \
  && gem install bundler

COPY --from=node /usr/local/bin/node /usr/local/bin/
COPY --from=node /usr/local/lib/node_modules /usr/local/lib/node_modules
RUN ln -s /usr/local/lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm \
  && ln -s /usr/local/lib/node_modules/npm/bin/npx-cli.js /usr/local/bin/npx \
  && npm install -g pnpm@${PNPM_VERSION}

WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN bundle config set --local force_ruby_platform true \
  && bundle config set without 'development test' \
  && bundle install -j 4 -r 3

COPY package.json pnpm-lock.yaml ./
RUN pnpm i

# Copia todo o projeto
COPY . /app

# Sobrescreve com os arquivos modificados (já estão no COPY acima pois vêm do repo)
# Compila os assets com os arquivos modificados
RUN SECRET_KEY_BASE=precompile_placeholder RAILS_LOG_TO_STDOUT=enabled \
  bundle exec rake assets:precompile \
  && rm -rf spec node_modules tmp/cache

# final stage
FROM chatwoot/chatwoot:v4.9.1

USER root

# Copia os assets compilados com as alterações
COPY --from=pre-builder /app/public/packs /app/public/packs
COPY --from=pre-builder /app/public/assets /app/public/assets

# Copia arquivos backend modificados
COPY app/models/concerns/sort_handler.rb /app/app/models/concerns/sort_handler.rb
COPY app/finders/conversation_finder.rb /app/app/finders/conversation_finder.rb
