
# === {{CMD}}  ...
js_applet () {
    app_dir="Public/applets"
    mkdir -p $app_dir/$1
    file="$app_dir/$1/script.js"
    if [[ -f $file ]]
    then
      echo "=== Already exists: $file"
      exit 0
    fi
      echo -e "\"use strict\";\n" >> $file

    echo "Created: $file"
} # === end function
