#
# SPDX-FileCopyrightText: 2022 Wesley Schwengle <wesleys@opperschaap.net>
#
# SPDX-License-Identifier: Unlicense
#
KEY_DIR="$HOME/.Garmin/ConnectIQ"
mkdir -p "$KEY_DIR"

DER="$KEY_DIR/developer.der"

if [ -f "$DER" ]
then
  echo "You already have a developer key at $DER!" >&2
  exit 1;
fi

PEM="$(mktemp)"
openssl genrsa -out $PEM 4096
openssl pkcs8 -topk8 -nocrypt -inform PEM -outform DER -in  $PEM -out $DER
rm -f $PEM
chmod 600 $DER

echo "Developer key $DER created"
