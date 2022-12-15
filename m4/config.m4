dnl;
dnl; This is a comment!
dnl; This file contains a basic configuration
dnl; of the M4 preprocessor.
dnl;
dnl; All macros should start with `M_` and
dnl; be named using `SCREAMING_SNAKE_CASE`.
dnl; `<*` and `*>` are used as delimiters of verbatim text
dnl; that the M4 preprocessor will not attempt to resolve.
dnl;
changequote(`<*', `*>')dnl
dnl;
dnl; Define a newline macro
dnl;
define(<*M_NEWLINE*>, <*
*>)dnl
dnl;
dnl; Define an empty string macro
dnl;
define(<*M_EMPTY*>, <**>)dnl
dnl;
dnl; Define a macro which gets the value
dnl; of an environment variable.
dnl;
dnl; USAGE: M_ENV_VAR(<VARIABLE_NAME>)
dnl;
define(<*M_ENV_VAR*>, <*translit(esyscmd(echo $$1), M_NEWLINE)*>)dnl
