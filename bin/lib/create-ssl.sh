
# === {{CMD}}
# === This is out-of-date. It needs to be updated for dev and prod envs.
create-ssl () {
  args=" \
  --ssl --ssl-certificate $dir/ssl/server.crt \
  --ssl-certificate-key   $dir/ssl/server.key \
  --ssl-port 4568"

  folder="tmp/ssl"
  mkdir -p "$folder"
  cd $folder

  openssl genrsa -des3 -out server.key 1024

  # === For now, leave the challenge password and
  # company name blank.
  openssl req     -new -key server.key -out server.csr

  # === Remove password
  cp server.key server.key.org
  openssl rsa -in server.key.org -out server.key

  # === Generate a Self-Signed Certificate
  openssl x509 -req -days 30 -in server.csr -signkey server.key -out server.crt

  # sudo chown root:root server.*

  chmod 400 server.*

} # === end function
