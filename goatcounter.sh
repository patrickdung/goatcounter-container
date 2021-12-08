#!/usr/bin/env bash

# SPDX-License-Identifier: Apache-2.0

set -e

declare OPTS=""

OPTS="${OPTS} -listen ${GOATCOUNTER_LISTEN}"
#OPTS="${OPTS} -tls http"
OPTS="${OPTS} -tls ${GOATCOUNTER_TLS}"
OPTS="${OPTS} -db ${GOATCOUNTER_DB}"

if [ -v GOATCOUNTER_EMAIL_FROM ]; then
  OPTS="${OPTS} -email-from ${GOATCOUNTER_EMAIL_FROM}"
fi

# Needs bash >= ver 4.2
##if [ -n "${GOATCOUNTER_SMTP}" ]; then
if [ -v GOATCOUNTER_SMTP ]; then
  OPTS="${OPTS} -smtp ${GOATCOUNTER_SMTP}"
fi

##if [ -n "${GOATCOUNTER_DEBUG}" ]; then
if [ -v GOATCOUNTER_DEBUG ]; then
  OPTS="${OPTS} -debug all"
fi

if [[ -v GOATCOUNTER_AUTOMIGRATE ]] && [[ ${GOATCOUNTER_AUTOMIGRATE} == "true" ]]; then
  OPTS="${OPTS} -automigrate"
fi

/home/goatcounter/bin/goatcounter serve ${OPTS}
