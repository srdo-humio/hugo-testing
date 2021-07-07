#!/usr/bin/env bash

main() {
  declare -a languages
  declare language
  declare -a translations
  declare translation
  declare key

  # Create array of languages defined in site configuration.
  readarray -t languages < <(hugo config | grep "languages" | sed 's/languages = map\[/\]/' | sed 's/:map/\n/g' | head -n-1 | awk -F'[\\]]' '{print $2}' | sed 's/ //g')

  # Create i18n files.
  mkdir -p "i18n"
  for language in "${languages[@]}"; do
    touch "i18n/${language}.toml"
  done

  # Create array of missing translations. Example:
  #
  #   en|date_created
  #   en|title
  #   es|date_created
  #   es|title
  readarray -t translations < <(hugo --i18n-warnings | grep "i18n" | sort | awk -F'|' '{print $3 "|" $4}')

  # Update i18n files.
  for translation in "${translations[@]}"; do
    language=$(awk -F'|' '{print $1}' <<< "${translation}")
    key=$(awk -F'|' '{print $2}' <<< "${translation}")
    echo "${key}=\" \"" >> "i18n/${language}.toml"
  done
}

set -euo pipefail
main "$@"
