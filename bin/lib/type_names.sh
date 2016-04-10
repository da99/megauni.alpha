
# === {{CMD}}
# === Prints out the different types of db Links.
type_names () {
  # === mksh> type_names
  # ===    ME_ONLY
  # ===    ...
  IFS=$'\n'
  for line in $(cat lib/Link/migrates/__-link_type_id.sql)
  do
    if [[ $line =~ ^[[:space:]]+WHEN[[:space:]]+.+THEN ]]; then
      IFS="'" read -ra WORDS <<< "$line"
      code="$(mksh_setup string_to_num "${WORDS[1]}")"

      start_keeping=""
      comment=""
      while read -n1 comm_char; do
        if [[ -n "$start_keeping" ]] ; then
          comment="${comment}${comm_char}"
        else
          if [[ "$comm_char" == "-"  ]]; then
            comment="-"
            start_keeping="yes"
          fi;
        fi;
      done < <(echo -n "$line")

      IFS=' -- ' read -ra COMMENTS <<< "$line"
      # echo "${WORDS[1]} $code ${comment}"
      echo "WHEN '${WORDS[1]}'    THEN RETURN $code; $comment"
    fi

  done
} # === end function
