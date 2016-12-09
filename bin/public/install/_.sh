
# === {{CMD}} ...
install () {

  echo ""
  echo "# === Installing PGCRYPTO extension."
  sudo -u postgres psql "$DATABASE_NAME" -c "CREATE EXTENSION IF NOT EXISTS pgcrypto;"

  echo ""

  bin/install_nodejs
  bin/install_nginx_conf
  bin/install_pg
  bin/install_gems

  sh_color BOLD "=== Adding '{{git push}}' urls"
  ORIGIN_FETCH="$(git remote -v | grep 'origin' | grep '(fetch)' | head -n1 | cut -f2 | cut -d ' ' -f1)"
  BITBUCKET="git@bitbucket:da99/megauni.git"

  # === Delete possible duplicates:
  git remote set-url --push --delete origin "$BITBUCKET"
  git remote set-url --push --delete origin "$ORIGIN_FETCH"

  # === Finall, add URLS:
  git remote set-url --push --add    origin "$BITBUCKET"
  git remote set-url --push --add    origin ${ORIGIN_FETCH}
  git remote -v

  if [[ -d nginx ]]; then
    sh_color BOLD "=== Skipping local install: {{NGINX}}"
  else
    sh_color BOLD "=== Installing local {{NGINX}}:"
    mkdir -p tmp
    nginx_setup install " --error-log-path=${THIS_DIR}/tmp/nginx.startup.log "
  fi
} # === end function
