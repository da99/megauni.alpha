

nginx () {

  mkdir -p logs
  mkdir -p tmp

  # === We render all possible ENV conf files to make sure they have all
  # === specified variables written in each ENV.
  mksh_setup template-render "config/DEV"  "config/nginx.conf"   > progs/nginx.DEV.conf
  mksh_setup template-render "config/PROD" "config/nginx.conf"   > progs/nginx.PROD.conf

  local +x CMD="progs/nginx/sbin/nginx  -c $THIS_DIR/progs/nginx.$($0 server server-env).conf  -p $THIS_DIR"
  echo "$CMD $@" >&2
  $CMD "$@"

} # === end function
