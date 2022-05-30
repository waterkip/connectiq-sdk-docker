KEY_DIR="$HOME/.Garmin/ConnectIQ"
mkdir -p "$KEY_DIR"

PEM="$KEY_DIR/developer.pem"
DER="$KEY_DIR/$(basename $PEM .pem).der"

if [ -f "$DER" ]
then
  echo "You already have a developer key at $DER!" >&2
  exit 1;
fi

openssl genrsa -out $PEM 4096
openssl pkcs8 -topk8 -nocrypt -inform PEM -outform DER -in  $PEM -out $DER
rm -f $PEM
chmod 600 $DER

echo "Developer key $DER created"
