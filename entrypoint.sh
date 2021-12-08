#!/usr/bin/env bash

# SPDX-License-Identifier: Apache-2.0

set -eu

create_site ()
{
  echo "Creating a site with goatcounter"
  /home/goatcounter/bin/goatcounter db create site \
    -createdb \
    -vhost "${GOATCOUNTER_VHOST}" \
    -user.email "${GOATCOUNTER_ADMIN_EMAIL}" \
    -user.password "${GOATCOUNTER_PASSWORD}" \
    -db "${GOATCOUNTER_DB}"
}

if [ ${GOATCOUNTER_INITDB} == "true" ]; then
  # silence any errors
  if ! create_site; then
    /bin/true
  fi
fi

exec "$@"
