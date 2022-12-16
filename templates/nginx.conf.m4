dnl;
dnl; This file should be preprocessed by GNU M4
dnl; https://www.gnu.org/software/m4/manual/m4.html
dnl;
include(`config.m4')dnl
define(<*M_NGINX_SSL_CERT_FILE*>, M_ENV_VAR(NGINX_SSL_CERT_FILE))dnl
define(<*M_NGINX_SSL_KEY_FILE*>, M_ENV_VAR(NGINX_SSL_KEY_FILE))dnl
define(<*M_NGINX_PUBLIC_PATH*>, M_ENV_VAR(NGINX_PUBLIC_PATH))dnl
define(<*M_NGINX_ACCESS_LOG*>, M_ENV_VAR(NGINX_ACCESS_LOG))dnl
define(<*M_NGINX_ERROR_LOG*>, M_ENV_VAR(NGINX_ERROR_LOG))dnl
define(<*M_LAMBDEE_HOST*>, M_ENV_VAR(LAMBDEE_HOST))dnl
define(<*M_NGINX_WEB_SERVICE_HOST*>, M_ENV_VAR(NGINX_WEB_SERVICE_HOST))dnl
define(<*M_NGINX_SCRIPT_SERVICE_HOST*>, M_ENV_VAR(NGINX_SCRIPT_SERVICE_HOST))dnl
define(<*M_USE_SSL*>, M_ENV_VAR(USE_SSL))dnl
dnl;
# WebSocket setup
map $http_upgrade $connection_upgrade {
    default upgrade;
    '' close;
}
dnl;
dnl; if the `$USE_SSL` env variable is set
dnl; then render this server block
dnl; (redirect from HTTP to HTTPS)
dnl;
ifelse(M_USE_SSL, M_EMPTY, M_EMPTY, <*
server {
  listen 80;
  listen [::]:80;
  server_name M_LAMBDEE_HOST;
  return 301 https://$host$request_uri;
}
*>)
upstream web_server {
  server M_NGINX_WEB_SERVICE_HOST:3000;
}

upstream script_service_server {
  server M_NGINX_SCRIPT_SERVICE_HOST:3001;
}

server {
  server_name M_LAMBDEE_HOST;
ifelse(M_USE_SSL, M_EMPTY, <*
  listen 80;
*>,
<*
  listen 443 ssl;

  ssl_certificate M_NGINX_SSL_CERT_FILE;
  ssl_certificate_key M_NGINX_SSL_KEY_FILE;
  ssl_verify_depth 2;
*>)

  # nginx will search for static files there
  root   M_NGINX_PUBLIC_PATH;
  index  index.html;

  # define where Nginx should write its logs
  access_log M_NGINX_ACCESS_LOG;
  error_log M_NGINX_ERROR_LOG;

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
    proxy_pass http://web_server;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header Host $host;
    proxy_redirect off;
  }

}
