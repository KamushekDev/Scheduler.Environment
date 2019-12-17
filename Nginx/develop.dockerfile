FROM nginx
COPY nginx.conf /etc/nginx/
COPY develop.web.conf /etc/nginx/web.conf