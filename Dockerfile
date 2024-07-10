# syntax=docker/dockerfile:1.2

ARG NODE_VERSION=18.20.0
FROM node:${NODE_VERSION}-alpine as base

RUN apk update && apk add --no-cache \
    build-base \
    gcc \
    autoconf \
    automake \
    zlib-dev \
    libpng-dev \
    nasm \
    bash \
    vips-dev

WORKDIR /usr/src/app
EXPOSE 1337

RUN chown -R node:node /usr/src/app

FROM base as dev
COPY --chown=node:node package.json yarn.lock ./
RUN --mount=type=cache,target=/usr/local/share/.cache/yarn/v6 \
    yarn install --production=false
COPY --chown=node:node . .
ENV PATH /usr/src/app/node_modules/.bin:$PATH
USER node
CMD ["yarn", "develop"]

FROM base as prod
COPY --chown=node:node package.json yarn.lock ./
RUN --mount=type=cache,target=/usr/local/share/.cache/yarn/v6 \
    yarn install --production=true
COPY --chown=node:node . .
ENV PATH /usr/src/app/node_modules/.bin:$PATH
USER node
RUN yarn strapi build
CMD ["yarn", "strapi", "start"]
