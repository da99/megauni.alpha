
# === {{CMD}} ...
install () {
  bash_setup BOLD "=== Adding '{{git push}}' urls"
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
    bash_setup BOLD "=== Skipping local install: {{NGINX}}"
  else
    bash_setup BOLD "=== Installing local {{NGINX}}:"
    nginx_setup install
  fi
} # === end function
