#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

UPSTREAM_OWNER="runkids"
UPSTREAM_REPO="skillshare"

CURRENT_VERSION=$(sed -n 's/.*version = "\([^"]*\)";.*/\1/p' "$REPO_DIR/default.nix" | head -1)
if [ -z "$CURRENT_VERSION" ]; then
  echo "Could not determine current version from default.nix." >&2
  exit 1
fi

echo "Current version: $CURRENT_VERSION"

curl_args=(-sfL)
if [ -n "${GITHUB_TOKEN:-${GH_TOKEN:-}}" ]; then
  curl_args+=(
    -H "Authorization: Bearer ${GITHUB_TOKEN:-$GH_TOKEN}"
    -H "X-GitHub-Api-Version: 2022-11-28"
  )
fi

RELEASE_JSON=$(curl "${curl_args[@]}" "https://api.github.com/repos/${UPSTREAM_OWNER}/${UPSTREAM_REPO}/releases/latest")
LATEST_TAG=$(jq -r '.tag_name' <<<"$RELEASE_JSON")
if [ -z "$LATEST_TAG" ] || [ "$LATEST_TAG" = "null" ]; then
  echo "Could not determine latest GitHub release tag." >&2
  exit 1
fi

LATEST_VERSION="${LATEST_TAG#v}"
echo "Latest GitHub release: $LATEST_TAG"

if [ "$CURRENT_VERSION" = "$LATEST_VERSION" ]; then
  echo "Already up to date."
  if [ -n "${GITHUB_OUTPUT:-}" ]; then
    echo "UPDATED=false" >> "$GITHUB_OUTPUT"
  fi
  exit 0
fi

SYSTEMS=(
  "x86_64-darwin"
  "aarch64-darwin"
  "x86_64-linux"
  "aarch64-linux"
)

ASSETS=(
  "skillshare_${LATEST_VERSION}_darwin_amd64.tar.gz"
  "skillshare_${LATEST_VERSION}_darwin_arm64.tar.gz"
  "skillshare_${LATEST_VERSION}_linux_amd64.tar.gz"
  "skillshare_${LATEST_VERSION}_linux_arm64.tar.gz"
)

WORK_DIR=$(mktemp -d)
trap 'rm -rf "$WORK_DIR"' EXIT

declare -A HASHES

for index in "${!SYSTEMS[@]}"; do
  system="${SYSTEMS[$index]}"
  asset="${ASSETS[$index]}"
  url=$(jq -r --arg name "$asset" '.assets[] | select(.name == $name) | .browser_download_url' <<<"$RELEASE_JSON")

  if [ -z "$url" ] || [ "$url" = "null" ]; then
    echo "Could not find release asset for ${system}: ${asset}" >&2
    jq -r '.assets[].name' <<<"$RELEASE_JSON" >&2
    exit 1
  fi

  echo "Downloading ${asset}..."
  curl -sfL "$url" -o "$WORK_DIR/$asset"
  HASHES[$system]=$(nix hash path --mode flat "$WORK_DIR/$asset")
done

awk \
  -v oldVersion="$CURRENT_VERSION" \
  -v newVersion="$LATEST_VERSION" \
  -v x86_64_darwin="${HASHES[x86_64-darwin]}" \
  -v aarch64_darwin="${HASHES[aarch64-darwin]}" \
  -v x86_64_linux="${HASHES[x86_64-linux]}" \
  -v aarch64_linux="${HASHES[aarch64-linux]}" \
  '
    {
      gsub("version = \"" oldVersion "\"", "version = \"" newVersion "\"")
    }

    /"x86_64-darwin" = fetchurl/ { system = "x86_64-darwin" }
    /"aarch64-darwin" = fetchurl/ { system = "aarch64-darwin" }
    /"x86_64-linux" = fetchurl/ { system = "x86_64-linux" }
    /"aarch64-linux" = fetchurl/ { system = "aarch64-linux" }

    /hash = "/ {
      if (system == "x86_64-darwin") {
        sub(/hash = "[^"]*"/, "hash = \"" x86_64_darwin "\"")
        system = ""
      } else if (system == "aarch64-darwin") {
        sub(/hash = "[^"]*"/, "hash = \"" aarch64_darwin "\"")
        system = ""
      } else if (system == "x86_64-linux") {
        sub(/hash = "[^"]*"/, "hash = \"" x86_64_linux "\"")
        system = ""
      } else if (system == "aarch64-linux") {
        sub(/hash = "[^"]*"/, "hash = \"" aarch64_linux "\"")
        system = ""
      }
    }

    { print }
  ' "$REPO_DIR/default.nix" > "$REPO_DIR/default.nix.tmp"
mv "$REPO_DIR/default.nix.tmp" "$REPO_DIR/default.nix"

echo "Updated skillshare to $LATEST_VERSION"

if [ -n "${GITHUB_OUTPUT:-}" ]; then
  echo "VERSION=$LATEST_VERSION" >> "$GITHUB_OUTPUT"
  echo "UPDATED=true" >> "$GITHUB_OUTPUT"
fi
