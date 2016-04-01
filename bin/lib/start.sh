
source "$THIS_DIR/bin/lib/nginx.sh"
source "$THIS_DIR/bin/lib/stop.sh"
source "$THIS_DIR/bin/lib/is-server-running.sh"

# === {{CMD}} start         # To be used on dev machines only.
# === {{CMD}} start -nginx -args
start () {
  if is-server-running; then
    mksh_setup ORANGE "=== Server is already {{running}}."
    return 0
  fi

  nginx -t
  nginx
  mksh_setup max-wait 5s "megauni is-server-running"
  mksh_setup GREEN "=== Server is {{running}}."
  return 0
  # ====================================================

    if [[ "$@" == *watch* ]]; then
      rm -f tmp/wait.for.file.change.txt
      inotifywait --quiet --monitor --event close_write -r lib/ ./*.ex*  | while read -r CHANGE
      do
        dir=$(echo "$CHANGE" | cut -d' ' -f 1)
        op=$(echo "$CHANGE" | cut -d' ' -f 2)
        file=$(echo "$CHANGE" | cut -d' ' -f 3)
        path="${dir}$file"
        file=$(basename $path)
        echo -e "=== $CHANGE ($path)"
        rm -f tmp/wait.for.file.change.txt
        if [[ ! -f /tmp/compile.megauni ]]; then
          bin/megauni stop || :
        fi
      done
      exit 0
    fi


    export IS_RUNNING_WWW_SERVER="true"
    export MIX_ENV="prod"

    elixir="elixir --no-halt"
    cmd="-S mix do compile, megauni.server"

    # === if on a non-DEV machine:
    if ! mksh_setup dev!; then
      $elixir --detached $cmd
      exit 0
    fi

    # === DEV machine:
    touch /tmp/erl_crash.dump
    rm -f erl_crash.dump
    ln -s /tmp/erl_crash.dump erl_crash.dump

    ( bin/megauni start watch ) &
    exit_code="-1"
    while [[ "$exit_code" != "0" ]]
    do
      echo ""
      echo "=== Starting server..." 1>&2
      $elixir $cmd && exit_code="0" || exit_code=$?
      if [[ "$exit_code" == "1" ]]; then
        echo -n "=== Exited: $exit_code Waiting..."
        touch tmp/wait.for.file.change.txt
        while [[ -f tmp/wait.for.file.change.txt ]]
        do
          sleep 3
          echo -n "."
        done
      else
        sleep 0
      fi
    done
} # === end function
