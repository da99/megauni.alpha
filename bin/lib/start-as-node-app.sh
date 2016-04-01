
# === {{CMD}}  ...
start-as-node-app () {
    if [[ -n "$dev" && -z "$USE_SERVER" ]]; then
      echo "=== Not starting server."
      exit 0
    fi
    PORT=$PORT $0 pm2 startOrGracefulReload megauni.pm2.json5 "$@"
    exit 0

    dir="$(pwd)/tmp"
    args=""
    if [[ ! -z "$dev" ]]; then
      args=" \
      --ssl --ssl-certificate $dir/ssl/server.crt \
      --ssl-certificate-key   $dir/ssl/server.key \
      --ssl-port 4568"
    fi

    if [[ ! -z "$dev" && ! -d tmp/ssl ]]; then
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
    fi

    # puma --config configs/puma.rb configs/config.ru


    # More options at:
    # https://github.com/phusion/passenger/blob/master/lib/phusion_passenger/standalone/start_command.rb
    RACK_ENV=production bundle exec passenger start   \
      $args                                           \
      --pid-file=$dir/4567.pid                        \
      --log-file=$dir/4567.log                        \
      --port 4567                                     \
      --rackup configs/config.ru                      \
      --static-files-dir      $dir/../Public
} # === end function
