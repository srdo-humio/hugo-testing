#!/usr/bin/env bash

main() {
  declare anchor
  declare anchors
  declare destination_url
  declare file
  declare files
  declare publish_dir=public
  declare source_linktitle
  declare source_path
  declare source_permalink
  declare source_relpermalink
  declare source_title
  declare destination_url
  declare heredoc
  declare output_file=data/backlinks.json
  declare i=0

  mkdir -p "$(dirname "${output_file}")"

  echo "[" > "${output_file}"

  readarray -d '' files < <(find "${publish_dir}" -type f -name "*.html" -print0)
  for file in "${files[@]}"; do
    readarray -t anchors < <(xmllint --html --xpath '//a[@class="internal-link"]' "${file}" 2>/dev/null)
    for anchor in "${anchors[@]}"; do
      if [[ "$i" -gt 0 ]]; then
        echo "," >> "${output_file}"
      fi
      ((i++)) || true

      source_linktitle=$(xmllint --html --xpath 'string(//a/@data-source-linktitle)' <(printf "%s" "${anchor}"))
      source_path=$(xmllint --html --xpath 'string(//a/@data-source-path)' <(printf "%s" "${anchor}"))
      source_permalink=$(xmllint --html --xpath 'string(//a/@data-source-permalink)' <(printf "%s" "${anchor}"))
      source_relpermalink=$(xmllint --html --xpath 'string(//a/@data-source-relpermalink)' <(printf "%s" "${anchor}"))
      source_title=$(xmllint --html --xpath 'string(//a/@data-source-title)' <(printf "%s" "${anchor}"))
      destination_url=$(xmllint --html --xpath 'string(//a/@href)' <(printf "%s" "${anchor}"))

      heredoc=$(cat <<EOT
  {
    "destination_url": "${destination_url}",
    "LinkTitle": "${source_linktitle}",
    "Path": "${source_path}",
    "Permalink": "${source_permalink}",
    "RelPermalink": "${source_relpermalink}",
    "Title": "${source_title}"
  }
EOT
      )

      echo -n "${heredoc}" >> "${output_file}"
    done
  done

  echo -e "\\n]" >> "${output_file}"
}

set -euo pipefail
main "$@"
