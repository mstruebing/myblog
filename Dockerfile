FROM klakegg/hugo:0.95.0-alpine AS build

WORKDIR /src
COPY . /src

RUN hugo build

FROM nginx:1.21.6-alpine

COPY --from=build /src/public /usr/share/nginx/html
EXPOSE 80
