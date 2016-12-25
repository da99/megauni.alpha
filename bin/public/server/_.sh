
source "$THIS_DIR/bin/public/nginx/_.sh"

# === {{CMD}} start
# === {{CMD}} pid    # prints pid number. Exits 1 if no pid found.
# === {{CMD}} reload
# === {{CMD}} quit   # (graceful shutdown)
homepage () {
  local +x PORT="$(netstat -tulpn 2>/dev/null | grep "$(server pid)/" | grep -Po ":\K(\d+)" )"
  local +x LOCAL="http://localhost:$PORT"
  sh_color BOLD "{{$LOCAL}}"
} # === homepage

server () {
  case "$1" in
    start)
      if server is-running; then
        sh_color ORANGE "=== Server is already {{running}}: $(homepage)"
        return 0
      fi

      nginx -t
      nginx

      mksh_setup max-wait 5s "$0 server is-running"
      sh_color GREEN "=== Server is {{running}}: $(homepage)"
      return 0
      ;;

    restart)
      server quit
      server start
      ;;


    pid)
      local +x found=""
      local +x IFS=$'\n'
      for FILE in $(find progs -type f -iname "*.pid" ! -size 0) ; do
        cat "$FILE"
        found="yes"
      done

      if [[ -z "$found" ]]; then
        return 1
      fi
      ;;

    reload)
      if ! $0 server pid >/dev/null; then
        $0 server start
        return 0
      fi

      nginx  -s reload
      sh_color BOLD "=== NGINX .conf has been {{reloaded}}."
      ;;


    stop)
      sh_color GREEN "=== You want {{quit}} (graceful shutdown) not RED{{stop}} (immediate stop)." 1>&2
      exit 1
      ;;

    quit)
      if ! server is-running; then
        sh_color ORANGE "=== Server is already {{shutdown}}."
        return 0
      fi

      echo "=== Quitting (ie graceful shutdown)..."
      nginx -s quit

      if server is-running; then
        sh_color RED "!!! Something went wrong. Server is {{still running}}."
        return 1
      fi
      ;;

    server-env)
      if [[ -z "${IS_DEV:-}" ]] ; then
        echo "PROD"
      else
        echo "DEV"
      fi
      ;;

    is-running)
      # pgrep -f "elixir.+megauni\.server(\s|$|,)" || (echo "=== No process found" 1>&2)
      if [[ ! -z "$(server pid || :)" ]] &&  ( ps aux | grep megauni | grep --color=always nginx ) >/dev/null ; then
        return 0
      fi
      return 1
      ;;

    *)
      sh_color RED "!!! Unknown server command: {{$@}}"
      exit 1
  esac
} # === end function
