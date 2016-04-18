#!/usr/bin/env mksh
# -*- mksh -*-
#

# === {{CMD}}
upgrade () {

  local +x ORIGIN="/lib/browser/build/browser.js"
  local +x FILE="Public/vendor/dum_dum_boom_boom.js"

  mkdir -p Public/vendor


  if [[ -d /apps/dum_dum_boom_boom ]]; then
    cp -vf /apps/dum_dum_boom_boom$ORIGIN "$FILE"
    return 0
  fi

  if [[ -d /progs/dum_dum_boom_boom ]]; then
    cd /progs/dum_dum_boom_boom
    git pull
    cp -vf /progs/dum_dum_boom_boom$ORIGIN "$FILE"
    return 0
  fi

  cd Public/vendor
  wget -q -O "$FILE" https://github.com/da99/dum_dum_boom_boom/raw/master$ORIGIN

  return 0 # ===================================================================

  local +x js="Public/vendor"
  local +x base_file="$js/all.js"

  rm -f "$base_file"
  re_download "$js/jquery.cookie.js" "https://raw.github.com/carhartl/jquery-cookie/master/jquery.cookie.js"
  re_download "$js/doT.js"           "https://raw.github.com/olado/doT/master/doT.min.js"
  re_download "$js/promise.js"       "https://raw.github.com/stackp/promisejs/master/promise.min.js"
  re_download "$js/form2json.js"     "https://raw.github.com/marioizquierdo/jquery.serializeJSON/master/jquery.serializeJSON.min.js"
  # re_download "$js/Hyper_JS.js"    "https://raw.github.com/da99/Hyper_JS/master/Hyper_JS.js"
  # re_download "jquery.sortElements.js" "https://raw.github.com/padolsey/jQuery-Plugins/master/sortElements/jquery.sortElements.js"

} # === upgrade ()

function re_download {
  if [[ ! "$flips" == *skip_download* ]]
  then
    rm -f "$1"
    wget -O "$1" "$2"
  fi
  cat  "$1" >> "$base_file"
  echo ""   >> "$base_file"
} # === re_download



