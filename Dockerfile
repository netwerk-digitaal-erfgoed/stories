FROM nginx:stable-alpine
LABEL org.opencontainers.image.source=https://github.com/netwerk-digitaal-erfgoed/stories
COPY ./html /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
