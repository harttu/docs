# 2023-02-13 How to configure SSL to work in Doccano

## You need SSL certificates
- Get them from (certbot)[https://certbot.eff.org/]
- Make your own certificates: 
```bash
openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -sha256 -days 3650 -nodes
```
- Use defaults in /etc/ssl :
Public certificate:
/etc/ssl/certs/ssl-cert-snakeoil.pem
and private in:
/etc/ssl/private/ssl-cert-snakeoil.key

## Dockerfile

Copy cert and key in folder that *can be read* without root. Copy them e.g. ~/repos/deccano/ssl.
Also changes ports options:

```docker
   volumes:
      - /home/username/repos/doccano/docker/nginx/default.conf:/etc/nginx/conf.d/default.conf:ro
      - /home/username/repos/doccano/docker/ssl:/etc/ssl_host/:ro
      - static_volume:/static
      - media:/media
    ports:
      - 80:8080
      - 443:8443
 ```

To use SSL in backend, add the following:

```docker
SESSION_COOKIE_SECURE: "True"
CSRF_COOKIE_SECURE: "True"
CSRF_TRUSTED_ORIGINS: "https://your_ip_or_domain_name_here"
```

doccano/docker/nginx/docker-compose.prod.yml file:

```docker
version: "3.7"
services:

  backend:
    image: doccano/doccano:backend
    volumes:
      - static_volume:/backend/staticfiles
      - media:/backend/media
      - tmp_file:/backend/filepond-temp-uploads
    environment:
      ADMIN_USERNAME: "${ADMIN_USERNAME}"
      ADMIN_PASSWORD: "${ADMIN_PASSWORD}"
      ADMIN_EMAIL: ${ADMIN_EMAIL}
      CELERY_BROKER_URL: "amqp://${RABBITMQ_DEFAULT_USER}:${RABBITMQ_DEFAULT_PASS}@rabbitmq"
      DATABASE_URL: "postgres://${POSTGRES_USER}:${POSTGRES_PASSWORD}@postgres:5432/${POSTGRES_DB}?sslmode=disable"
      ALLOW_SIGNUP: "False"
      DEBUG: "False"
      DJANGO_SETTINGS_MODULE: "config.settings.production"
      SESSION_COOKIE_SECURE: "True"
      CSRF_COOKIE_SECURE: "True"
      CSRF_TRUSTED_ORIGINS: "https://your_ip_or_domain_name_here"
    depends_on:
      - postgres
    networks:
      - network-backend
      - network-frontend

  celery:
    image: doccano/doccano:backend
    volumes:
      - media:/backend/media
      - tmp_file:/backend/filepond-temp-uploads
    entrypoint: ["/opt/bin/prod-celery.sh"]
    environment:
      PYTHONUNBUFFERED: "1"
      CELERY_BROKER_URL: "amqp://${RABBITMQ_DEFAULT_USER}:${RABBITMQ_DEFAULT_PASS}@rabbitmq"
      DATABASE_URL: "postgres://${POSTGRES_USER}:${POSTGRES_PASSWORD}@postgres:5432/${POSTGRES_DB}?sslmode=disable"
      DJANGO_SETTINGS_MODULE: "config.settings.production"
    depends_on:
      - postgres
      - rabbitmq
    networks:
      - network-backend


  flower:
    image: doccano/doccano:backend
    entrypoint: ["/opt/bin/prod-flower.sh"]
    environment:
      PYTHONUNBUFFERED: "1"
      CELERY_BROKER_URL: "amqp://${RABBITMQ_DEFAULT_USER}:${RABBITMQ_DEFAULT_PASS}@rabbitmq"
      DATABASE_URL: "postgres://${POSTGRES_USER}:${POSTGRES_PASSWORD}@postgres:5432/${POSTGRES_DB}?sslmode=disable"
      DJANGO_SETTINGS_MODULE: "config.settings.production"
      FLOWER_BASIC_AUTH: "${FLOWER_BASIC_AUTH}" # Format "username:password"
    depends_on:
      - celery
    ports:
      - 5555:5555
    networks:
      - network-backend
      - network-frontend

  rabbitmq:
    image: rabbitmq:3.10.7-alpine
    environment:
      RABBITMQ_DEFAULT_USER: "${RABBITMQ_DEFAULT_USER}"
      RABBITMQ_DEFAULT_PASS: "${RABBITMQ_DEFAULT_PASS}"
    ports:
      - 5672:5672
    networks:
      - network-backend

  nginx:
    image: doccano/doccano:frontend
    command: >
      /bin/sh -c
      "envsubst '
      $${WORKER_PROCESSES}
      '< /etc/nginx/nginx.conf.template
      > /etc/nginx/nginx.conf
      && nginx -g 'daemon off;'"
    environment:
      API_URL: "http://backend:8000"
      GOOGLE_TRACKING_ID: ""
      WORKER_PROCESSES: "auto"
   volumes:
      - /home/username/repos/doccano/docker/nginx/default.conf:/etc/nginx/conf.d/default.conf:ro
      - /home/username/repos/doccano/docker/ssl:/etc/ssl_host/:ro
      - static_volume:/static
      - media:/media
    ports:
      - 80:8080
      - 443:8443
    depends_on:
      - backend
    networks:
      - network-frontend

  postgres:
    image: postgres:13.3-alpine
    volumes:
      - postgres_data:/var/lib/postgresql/data/
    environment:
      POSTGRES_USER: "${POSTGRES_USER}"
      POSTGRES_PASSWORD: "${POSTGRES_PASSWORD}"
      POSTGRES_DB: "${POSTGRES_DB}"
    networks:
      - network-backend

volumes:
  postgres_data:
  static_volume:
  media:
  tmp_file:

networks:
  network-backend:
  network-frontend:
```

## Nginx file

The following setup in doccano/docker/nginx/defaul.conf
80 requests are forwarded to https. 

```nginx
server {
   listen 8080 default_server;
   server_name _;
   return 301 https://$host$request_uri;
}

server {
    listen 8443 ssl;
    
    ssl_certificate /etc/ssl_host/cert.pem;
    ssl_certificate_key /etc/ssl_host/key.pem;

    charset utf-8;
    client_max_body_size 100M;
    add_header X-Frame-Options DENY;
    add_header X-Content-Type-Options nosniff;
    add_header X-XSS-Protection "1; mode=block";

    location / {
        root /var/www/html;
        try_files $uri /index.html;
    }

    location /v1/ {
        proxy_pass http://backend:8000/v1/;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Host $host;
        proxy_redirect off;
        proxy_read_timeout  300;
    }

    location /admin/ {
        proxy_pass http://backend:8000/admin/;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Host $host;
        proxy_redirect off;
    }

    location = /admin {
        absolute_redirect off;
        return 301 /admin/;
    }

    location /swagger/ {
        proxy_pass http://backend:8000/swagger/;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Host $host;
        proxy_redirect off;
    }

    location = /swagger {
        absolute_redirect off;
        return 301 /swagger/;
    }

    location /static/ {
        autoindex on;
        alias /static/;
    }

    location /media/ {
        autoindex on;
        alias /media/;
    }
}

server_tokens off;
```
