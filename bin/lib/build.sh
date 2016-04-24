
# === {{CMD}}
reset-dir () {
  local +x DIR="$1"; shift
  if [[ "$DIR" != Public/applets/* ]]; then
    mksh_setup RED "!!! Invalid directory to reset: $DIR"
    exit 1
  fi
  rm -rf "$DIR"
  mkdir -p "$DIR"
}

build () {
  if [[ ! -z "$@" ]]; then
    mksh_setup RED "!!! Unknown options: $@"
    exit 1
  fi # =====================================================

  reset-dir Public/applets/

  $0 build-html "Server/Homepage"
  dum_dum_boom_boom copy-files  Server/Homepage  Public/applets/Homepage

  $0 build-html "Server/MUE"
  dum_dum_boom_boom copy-files  Server/MUE  Public/applets/MUE

  $0 build-js   "Server/Browser/Megauni"

  local +x JS_FILES=$(find Public/applets -type f -name "*.js")
  # mksh_setup ORANGE "=== {{eslinting}}: $JS_FILES"

  js_setup eslint browser $JS_FILES
  # tput cuu1; tput el
  # mksh_setup GREEN "=== {{Passed}} eslint: $JS_FILES"

  mksh_setup GREEN "=== Done {{building}}."
} # === end function
