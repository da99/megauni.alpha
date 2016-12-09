#!/usr/bin/env mksh
# -*- mksh -*-
#

# === {{CMD}}
# === Can only be run on a DEV machine.
upgrade () {

  if [[ -z "$IS_DEV" ]]; then
    sh_color RED "=== Can only be run on a {{DEV}} machine."
    exit 1
  fi

  local +x ORIGIN="/lib/browser/build/browser.js"
  local +x LOCAL_PATH="/apps/dum_dum_boom_boom$ORIGIN"
  local +x FILE="Public/vendor/dum_dum_boom_boom.js"

  mkdir -p Public/vendor
  touch "$FILE"

  # === Copy dum_dum_boom_boom runtime:
  if [[ -d /apps/dum_dum_boom_boom ]] ; then
    if diff "$LOCAL_PATH" "$FILE" ; then
      sh_color BOLD "=== Already up to date: {{$FILE}}"
    else
      sh_color BOLD "=== Copying: {{$ORIGIN}} -> {{$FILE}}"
      cp -f "$LOCAL_PATH" "$FILE"
    fi
  else # === Copy from online git repo:
    rm -f "$FILE"
    wget -q -O "$FILE" https://github.com/da99/dum_dum_boom_boom/raw/master$ORIGIN
  fi

  lua_setup upgrade-openresty

} # === upgrade ()

