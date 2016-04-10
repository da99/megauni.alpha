
source "$THIS_DIR/bin/lib/server-env.sh"

nginx () {

  mkdir -p logs
  mkdir -p tmp
  nginx_setup mkconf "$(server-env)" "config/nginx.conf" > progs/nginx.conf
  local +x CMD="progs/nginx/sbin/nginx  -c $THIS_DIR/progs/nginx.conf  -p $THIS_DIR"
  $CMD "$@"
} # === end function
