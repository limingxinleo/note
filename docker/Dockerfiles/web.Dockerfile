FROM node:9-alpine

ENV TZ Asia/Shanghai

RUN apk add --update tzdata \
    && echo "${TZ}" > /etc/timezone \
    && ln -sf /usr/share/zoneinfo/${TZ} /etc/localtime \
    && mkdir -p /usr/src/app \
    && mkdir -p /usr/src/build
COPY . /usr/src/build
WORKDIR /usr/src/build
RUN yarn \
    && yarn run build \
    && rm -rf /usr/local/share/.cache/yarn \
    && mv /usr/src/build/dist /usr/src/app/dist \
    && mv /usr/src/build/index.js /usr/src/app \
    && rm -rf /usr/src/build
WORKDIR /usr/src/app
RUN yarn add static-web-proxy \
    && rm -rf /usr/local/share/.cache/yarn

ENTRYPOINT ["node","index"]
EXPOSE 3000