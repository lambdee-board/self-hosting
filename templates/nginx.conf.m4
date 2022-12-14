dnl;
dnl; This file should be preprocessed by GNU M4
dnl; https://www.gnu.org/software/m4/manual/m4.html
dnl;
include(`m4/config.m4')dnl
dnl;
# WebSocket setup
map $http_upgrade $connection_upgrade {
    default upgrade;
    '' close;
}

upstream rails_server {
  server rails:3000;
}

upstream script_service_server {
  server script-service:3001;
}

server {
  server_name localhost;
  listen 80;

  # nginx will search for static files there
  root   /usr/src/app/public;
  index  index.html;

  # define where Nginx should write its logs
  access_log /usr/src/app/log/access.log;
  error_log /usr/src/app/log/error.log;

  # deny requests for files that should never be accessed
  location ~ /\. {
    deny all;
  }

  location ~* ^.+\.(rb|log)$ {
    deny all;
  }

  # serve static (compiled) assets directly if they exist (for rails production)
  location ~ ^/(assets|images|javascripts|stylesheets|swfs|system)/ {
    access_log off;
    gzip_static on; # to serve pre-gzipped version

    expires max;
    add_header Cache-Control public;

    # Some browsers still send conditional-GET requests if there's a
    # Last-Modified header or an ETag header even if they haven't
    # reached the expiry date sent in the Expires header.
    add_header Last-Modified "";
    add_header ETag "";
    break;
  }

  # script service
  location /script-service/ {
    proxy_pass http://script_service_server;
    proxy_http_version 1.1;
    proxy_redirect off;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_read_timeout 3600s;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection $connection_upgrade;
  }

  location / {
    proxy_pass http://rails_server;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header Host $host;
    proxy_redirect off;
  }

}
