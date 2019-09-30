FROM nginx:latest

COPY nginx.conf /etc/nginx/nginx.conf

ENV WEB=/usr/share/nginx/html
COPY favicon.ico $WEB
COPY index.html $WEB
COPY static $WEB/static
