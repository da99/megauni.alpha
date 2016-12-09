
# === {{CMD}}
# === {{CMD}}  My_PERL_RegExp
run-specs () {
  if [[ -z "$@" ]]; then
    local +x SEARCH="/specs/[^/]+$"
  else
    local +x SEARCH="$1"; shift
  fi

  echo ""

  local +x IFS=$'\n'
  for DIR in $(find Server/ -mindepth 3 -maxdepth 3 -type d -path "*/specs/*" | sort --human-numeric-sort | grep -P "$SEARCH"); do
    for SPEC in $(sh_specs ls-specs "$DIR"); do
      local +x COMPUTER="$(basename "$(dirname "$(dirname "$DIR")")")"
      local +x SPEC_TYPE="$(basename $(dirname "$SPEC"))"
      sh_color BOLD "Server/ORANGE{{$COMPUTER}}/specs/{{$SPEC_TYPE}}/BOLD{{$(basename "$SPEC")}}"
      sh_specs run-file "$SPEC"
      echo ""
    done
  done
} # === end function
