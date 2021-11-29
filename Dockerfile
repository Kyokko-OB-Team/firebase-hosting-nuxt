FROM node:lts-alpine

RUN apk update && \
    npm install -g create-nuxt-app && \
    npm install -g firebase-tools

ENV HOST 0.0.0.0
EXPOSE 3000
