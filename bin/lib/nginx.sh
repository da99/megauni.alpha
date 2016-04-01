
# === {{CMD}}  ...
nginx () {
  if [[ -z "$IS_DEV" ]]; then
    local +x ENV_NAME="PROD"
  else
    local +x ENV_NAME="DEV"
  fi

  mkdir -p logs
  mkdir -p tmp
  nginx_setup mkconf "$ENV_NAME" "config/nginx.conf" > progs/nginx.conf
  local +x CMD="progs/nginx/sbin/nginx    -c $THIS_DIR/progs/nginx.conf -p $THIS_DIR"
  $CMD "$@"
} # === end function
