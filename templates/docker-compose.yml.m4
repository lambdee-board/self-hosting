dnl;
dnl; This file should be preprocessed by GNU M4
dnl; https://www.gnu.org/software/m4/manual/m4.html
dnl;
include(`m4/config.m4')dnl
define(<*M_LAMBDEE_HOME_DIR*>, M_ENV_VAR(LAMBDEE_HOME_DIR))dnl
dnl;
version: "3.9"
services:

  redis:
    image: redis
    expose:
      - '6379'
    networks:
      - kv_store
    restart: always

  postgres:
    image: postgres
    environment:
      POSTGRES_USER: ${DB_NAME}
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    expose:
      - '5432'
    volumes:
      - M_LAMBDEE_HOME_DIR/postgresql/data:/var/lib/postgresql/data
    networks:
      - db
    restart: always

  script-service:
    image: lambdee-board/script-service
    expose:
      - "3001"
    environment:
      RACK_ENV: production
      LAMBDEE_HOST: rails:3000
      LAMBDEE_PROTOCOL: http
      SCRIPT_SERVICE_API_USER: ${SCRIPT_SERVICE_API_USER}
      SCRIPT_SERVICE_API_PASSWORD: ${SCRIPT_SERVICE_API_PASSWORD}
      SCRIPT_SERVICE_SECRET: ${SCRIPT_SERVICE_SECRET}
    networks:
      - web
    volumes:
      - M_LAMBDEE_HOME_DIR/log/script_service:/usr/src/app/log
    restart: always

  rails:
    image: lambdee-board/rails
    expose:
      - "3000"
    environment:
      PORT: 3000
      RAILS_ENV: production
      RACK_ENV: production
      NODE_ENV: production
      DB_HOST: postgres
      DB_NAME: ${DB_NAME}
      DB_PASSWORD: ${DB_PASSWORD}
      REDIS_URL: 'redis://redis:6379/0'
      SECRET_KEY_BASE: ${SECRET_KEY_BASE}
      LAMBDEE_HOST: ${LAMBDEE_HOST}
      LAMBDEE_PROTOCOL: ${LAMBDEE_PROTOCOL}
      SCRIPT_SERVICE_API_USER: ${SCRIPT_SERVICE_API_USER}
      SCRIPT_SERVICE_API_PASSWORD: ${SCRIPT_SERVICE_API_PASSWORD}
      SCRIPT_SERVICE_EXTERNAL_HOST: ${LAMBDEE_HOST}/script-service/
      SCRIPT_SERVICE_INTERNAL_PROTOCOL: http
      SCRIPT_SERVICE_INTERNAL_HOST: script-service:3001
      SCRIPT_SERVICE_SECRET: ${SCRIPT_SERVICE_SECRET}
      SCRIPT_SERVICE_WS_PROTOCOL: ${SCRIPT_SERVICE_WS_PROTOCOL}
      JWT_SECRET_KEY: ${JWT_SECRET_KEY}
    depends_on:
      - postgres
      - script-service
    networks:
      - web
      - db
      - kv_store
    volumes:
      - lambdee-public-assets:/usr/src/app/public/assets
      - M_LAMBDEE_HOME_DIR/log/rails:/usr/src/app/log
    restart: always

  nginx:
    image: lambdee-board/nginx
    ports:
      - '${NGINX_HTTP_PORT}:80'
      - '${NGINX_HTTPS_PORT}:443'
    depends_on:
      - rails
    networks:
      - web
    volumes:
      - lambdee-public-assets:/usr/src/app/public/assets:ro
      - M_LAMBDEE_HOME_DIR/log/nginx:/usr/src/app/log
      - M_LAMBDEE_HOME_DIR/nginx:/etc/nginx/conf.d
    restart: always

volumes:
  lambdee-postgres:
  lambdee-public-assets:

networks:
  web:
  db:
  kv_store:
