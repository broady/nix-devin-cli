#!/usr/bin/env bash
# Fetches the latest Devin CLI manifest and updates manifest.json with
# current versions and SRI hashes for all supported Nix platforms.
set -euo pipefail

MANIFEST_URL="https://static.devin.ai/cli/current/manifest.json"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
OUTPUT="$SCRIPT_DIR/manifest.json"

upstream=$(curl -sSf "$MANIFEST_URL")
current_version=$(jq -r .version "$OUTPUT" 2>/dev/null || echo "")
new_version=$(echo "$upstream" | jq -r .version)

if [ "$current_version" = "$new_version" ]; then
  echo "Already up to date: $new_version"
  exit 0
fi

echo "Updating $current_version -> $new_version"

# Maps upstream platform triples to Nix system strings.
declare -A PLATFORM_MAP=(
  ["aarch64-apple-darwin"]="aarch64-darwin"
  ["x86_64-apple-darwin"]="x86_64-darwin"
  ["x86_64-unknown-linux"]="x86_64-linux"
  ["aarch64-unknown-linux"]="aarch64-linux"
)

# Build the new manifest.json with SRI hashes.
result=$(jq -n --arg version "$new_version" '{ version: $version, platforms: {} }')

for upstream_key in "${!PLATFORM_MAP[@]}"; do
  nix_system="${PLATFORM_MAP[$upstream_key]}"
  url=$(echo "$upstream" | jq -r ".platforms[\"$upstream_key\"].url")
  sha256_hex=$(echo "$upstream" | jq -r ".platforms[\"$upstream_key\"].sha256")

  if [ -z "$url" ] || [ "$url" = "null" ]; then
    echo "Warning: no URL for $upstream_key, skipping"
    continue
  fi

  # Convert hex SHA256 to SRI format (sha256-<base64>).
  sri_hash="sha256-$(echo -n "$sha256_hex" | xxd -r -p | base64)"

  result=$(echo "$result" | jq \
    --arg sys "$nix_system" \
    --arg url "$url" \
    --arg hash "$sri_hash" \
    '.platforms[$sys] = { url: $url, hash: $hash }')
done

echo "$result" | jq . > "$OUTPUT"
echo "Updated manifest.json to $new_version"
