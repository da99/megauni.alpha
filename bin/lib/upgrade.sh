#!/usr/bin/env mksh
# -*- mksh -*-
#

# === {{CMD}}
# === Can only be run on a DEV machine.
upgrade () {

  if [[ -z "$IS_DEV" ]]; then
    mksh_setup RED "=== Can only be run on a {{DEV}} machine."
    exit 1
  fi

  local +x ORIGIN="/lib/browser/build/browser.js"
  local +x FILE="Public/vendor/dum_dum_boom_boom.js"

  mkdir -p Public/vendor
  rm -f "$FILE"

  # === If we're on a dev machine
  if [[ -d /apps/dum_dum_boom_boom ]]; then
    mksh_setup BOLD "=== Copying: {{$ORIGIN}} -> {{$FILE}}"
    cp -f /apps/dum_dum_boom_boom$ORIGIN "$FILE"
    return 0
  fi

  wget -q -O "$FILE" https://github.com/da99/dum_dum_boom_boom/raw/master$ORIGIN

} # === upgrade ()

