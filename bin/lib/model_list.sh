
# === {{CMD}}  ...
model_list () {
    # === mksh> model_list
    # ===    User
    # ===    Screen_Name
    # === mksh> model_list rsort
    # ===    Screen_Name
    # ===    User

    if [[ "$@" == "rsort" ]]; then
      for (( idx=${#mods[@]}-1 ; idx >= 0 ; idx-- ))
      do
        echo "${mods[idx]}"
      done
    else
      for i in ${mods[@]}
      do
        echo "$i"
      done
    fi
} # === end function
