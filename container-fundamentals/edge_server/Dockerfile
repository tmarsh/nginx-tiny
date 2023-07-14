FROM test:image
LABEL org.opencontainers.image.authors="tim.marsh@sony.com"
LABEL org.opencontainers.image.source=https://github.com/tmarsh/container-fundamentals
LABEL org.opencontainers.image.description="Containter Fundamentals - Static Website Image"
LABEL org.opencontainers.image.licenses=APACHE2
#RUN apk update --no-cache
#RUN apk add --no-cache nginx

COPY config/nginx.conf /etc/nginx/
COPY web_content/ /var/www
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
