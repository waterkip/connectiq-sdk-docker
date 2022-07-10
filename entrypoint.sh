#!/bin/sh

# SPDX-FileCopyrightText: 2022 Wesley Schwengle <wesleys@opperschaap.net>
#
# SPDX-License-Identifier: Unlicense

set -e

export DBUS_SESSION_BUS_ADDRESS=$(dbus-daemon \
  --fork \
  --config-file=/usr/share/dbus-1/session.conf \
  --print-address)

exec "$@"
