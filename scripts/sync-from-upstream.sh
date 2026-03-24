#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd -- "$script_dir/.." && pwd)"
package_json="$repo_root/package.json"

if ! command -v git >/dev/null 2>&1; then
  echo "git is required" >&2
  exit 1
fi
if ! command -v jq >/dev/null 2>&1; then
  echo "jq is required" >&2
  exit 1
fi

owner="$(jq -r '.upstream.owner' "$package_json")"
repo="$(jq -r '.upstream.repo' "$package_json")"
requested_tag="${1:-}"

if [ -n "$requested_tag" ]; then
  tag="$requested_tag"
else
  tag="$(
    git ls-remote --tags --refs "https://github.com/$owner/$repo.git" 'v*' \
      | awk -F/ '{print $3}' \
      | sort -V \
      | tail -n 1
  )"
fi

if [ -z "$tag" ]; then
  echo "failed to determine upstream tag" >&2
  exit 1
fi

rev="$(
  git ls-remote "https://github.com/$owner/$repo.git" "refs/tags/$tag^{}" "refs/tags/$tag" \
    | tail -n 1 \
    | awk '{print $1}'
)"

if [ -z "$rev" ]; then
  echo "failed to resolve upstream revision for $tag" >&2
  exit 1
fi

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

echo "syncing $owner/$repo $tag ($rev)"
git clone --depth 1 --branch "$tag" "https://github.com/$owner/$repo.git" "$tmpdir/upstream" >/dev/null 2>&1

version="$(jq -r '.version' "$tmpdir/upstream/package.json")"

jq \
  --arg version "$version" \
  --arg tag "$tag" \
  --arg rev "$rev" \
  --arg dep_version "$version" \
  '.version = $version
   | .dependencies["context-mode"] = $dep_version
   | .upstream.tag = $tag
   | .upstream.rev = $rev' \
  "$package_json" > "$tmpdir/package.json"

mv "$tmpdir/package.json" "$package_json"

echo "updated:"
echo "  package: $package_json"
