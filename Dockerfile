FROM node:12.13-alpine AS builder
WORKDIR /usr/src/app
COPY package*.json ./
RUN npm install --only=development
COPY tsconfig*.json ./
COPY src src
RUN npm run build

FROM node:12-alpine AS production
ENV NODE_ENV=production
RUN apk add --no-cache tini
WORKDIR /usr/src/app
RUN chown node:node .
USER node
COPY package*.json ./
RUN npm install --only=production && echo "{}" > config.json
COPY --from=builder /usr/src/app/dist/ dist/
EXPOSE 3000
ENTRYPOINT [ "/sbin/tini","--", "node", "dist/main" ]