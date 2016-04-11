

nginx () {

  mkdir -p logs
  mkdir -p tmp
  nginx_setup mkconf "$($0 server server-env)" "config/nginx.conf" > progs/nginx.conf
  local +x CMD="progs/nginx/sbin/nginx  -c $THIS_DIR/progs/nginx.conf  -p $THIS_DIR"
  echo "$CMD $@" >&2
  $CMD "$@"

} # === end function
