
# === {{CMD}}
# === {{CMD}} reset
run-db-specs () {
  if ! mksh_setup is-dev ; then
    mksh_setup RED "!!! NOt a {{DEV}} machine."
    exit 1
  fi

  if [[ "$@" == "reset" ]]; then
    mariadb_setup drop-everything
    megauni UP
    return 0
  fi

  local +x SPEC_FILES="$(find Server/*/db-specs -mindepth 1 -maxdepth 1 -type f -name "*.sql" -print | sort -V)"

  if [[ -z "$SPEC_FILES" ]]; then
    mksh_setup RED "!!! {{No files found}}."
    exit 1
  fi

  local +x TEMP_FILE="$(mktemp /tmp/db.specs.XXXXXXXXXXXXXXXXX)"

  for SPEC_FILE in $SPEC_FILES; do
    local +x COMMENT="$(mariadb_setup sql TOP-COMMENT "$SPEC_FILE")"
    local +x EXPECT="$(cat "$SPEC_FILE" | mksh_setup lines-after "-- EXPECT" | mariadb_setup sql UNCOMMENT || :)"
    if [[ -z "$EXPECT" ]]; then
      mksh_setup RED "!!! No {{expect}} found: $SPEC_FILE"
      exit 1
    fi

    # === Reset tables by deleting all rows:
    for TABLE in $(mariadb_setup list-tables) ; do
      local +x CMD="DELETE FROM $TABLE;";
      echo "$CMD" | mysql
    done

    # === Run the SQL:
    local +x STAT="0"
    cat "$SPEC_FILE" | mysql --skip-column-names | tr '\t' ' ' > "$TEMP_FILE" && STAT="$?" || STAT="$?"
    local +x ACTUAL="$(cat "$TEMP_FILE")"

    # === Compare results:
    if [[ "$ACTUAL" != "$EXPECT" || "$STAT" -ne 0  ]]; then
      mksh_setup BOLD "$COMMENT"
      if [[ "$STAT" -eq 0 ]];
      then mksh_setup RED "Exit: BOLD{{$STAT}}";
      else mksh_setup RED "Exit: {{$STAT}}"
      fi
      mksh_setup RED    "{{MISMATCH}}:"
      mksh_setup ORANGE "BOLD{{ACTUAL}}:"
      mksh_setup ORANGE "$ACTUAL"

      mksh_setup ORANGE "BOLD{{EXPECT}}:"
      mksh_setup ORANGE "$EXPECT"
    else
      mksh_setup GREEN "=== {{Passed}}: BOLD{{$SPEC_FILE}}"
    fi
  done

  rm -f "$TEMP_FILE"
} # === end function
