dnl;
dnl; This file should be preprocessed by GNU M4
dnl; https://www.gnu.org/software/m4/manual/m4.html
dnl;
include(`config.m4')dnl
dnl;
# ENV variables for the docker-compose configuration
DB_NAME="M_ENV_VAR(DB_NAME)"
DB_PASSWORD="M_ENV_VAR(DB_PASSWORD)"
SECRET_KEY_BASE="M_ENV_VAR(SECRET_KEY_BASE)"
LAMBDEE_HOST="M_ENV_VAR(LAMBDEE_HOST)"
LAMBDEE_PROTOCOL="M_ENV_VAR(LAMBDEE_PROTOCOL)"
SCRIPT_SERVICE_API_USER="M_ENV_VAR(SCRIPT_SERVICE_API_USER)"
SCRIPT_SERVICE_API_PASSWORD="M_ENV_VAR(SCRIPT_SERVICE_API_PASSWORD)"
SCRIPT_SERVICE_SECRET="M_ENV_VAR(SCRIPT_SERVICE_SECRET)"
SCRIPT_SERVICE_WS_PROTOCOL="M_ENV_VAR(SCRIPT_SERVICE_WS_PROTOCOL)"
JWT_SECRET_KEY="M_ENV_VAR(JWT_SECRET_KEY)"
NGINX_HTTP_PORT="M_ENV_VAR(NGINX_HTTP_PORT)"
NGINX_HTTPS_PORT="M_ENV_VAR(NGINX_HTTPS_PORT)"
