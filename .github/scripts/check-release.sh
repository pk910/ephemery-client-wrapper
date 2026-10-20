#!/bin/bash
# Resolve the latest release of a client and decide whether a new wrapper image needs to be built.
# Used by the run-scheduled.yml and run-manual.yml workflows.
#
# Inputs (environment):
#   CLIENT_REPO          github repository (owner/name) the client releases are resolved from
#   SOURCE_IMAGE         upstream docker image (without tag)
#   SOURCE_IMAGE_PREFIX  optional prefix for the upstream image tag
#   TARGET_IMAGE         wrapper image to build (without tag)
#   CLIENT_VERSION       optional, build this version instead of the latest release
#   FORCE                "true" rebuilds even if the target image already exists
#   SOURCE_GRACE_HOURS   how long a fresh release may lack its source image before the job fails (default 24)
#   GITHUB_TOKEN         optional, used to look up the release age via the github api
#
# Outputs ($GITHUB_OUTPUT): client_release, source_image, target_image, need_build
# Exits 0 when there is nothing to build or the build info was written, 1 when the check itself failed.
set -euo pipefail

fail() { echo "::error::$*"; exit 1; }
warn() { echo "::warning::$*"; }

# age of a release in hours, empty if it cannot be determined
get_release_age_hours() {
  local repo="$1" tag="$2" published auth=()
  if [ -n "${GITHUB_TOKEN:-}" ]; then
    auth=(--header "Authorization: Bearer $GITHUB_TOKEN")
  fi
  published="$(curl --silent --fail --connect-timeout 10 --max-time 30 "${auth[@]}" \
    "https://api.github.com/repos/$repo/releases/tags/$tag" | jq -r '.published_at // empty')" || return 0
  [ -n "$published" ] || return 0
  echo $(( ($(date +%s) - $(date -d "$published" +%s)) / 3600 ))
}

client_repo="$CLIENT_REPO"
client_release="${CLIENT_VERSION:-}"
release_repo="$client_repo"

if [ -z "$client_release" ]; then
  # resolve the latest release via the release redirect, the github api is rate limited per ip.
  # follow all redirects: when a repository moves (consensys/teku -> Consensys-Incorporated/teku)
  # the first redirect only points to the new repository and not to the release tag.
  release_url="$(curl --silent --location --connect-timeout 10 --max-time 30 \
    --output /dev/null --write-out "%{url_effective}" "https://github.com/$client_repo/releases/latest" || true)"
  echo "release url: $release_url"
  if ! [[ "$release_url" =~ ^https://github\.com/([^/]+/[^/]+)/releases/tag/([^/]+)$ ]]; then
    fail "could not resolve the latest release of $client_repo (got '$release_url')"
  fi
  release_repo="${BASH_REMATCH[1]}"
  client_release="${BASH_REMATCH[2]}"
  if [ "$release_repo" != "$client_repo" ]; then
    warn "$client_repo has moved to $release_repo, update the repository in clients.yaml"
  fi
fi
echo "latest release: $client_release"

source_image="$SOURCE_IMAGE:${SOURCE_IMAGE_PREFIX:-}$client_release"
echo "check source image: $source_image"
if ! docker manifest inspect "$source_image" >/dev/null 2>&1; then
  # upstream usually publishes the image shortly after the release, tolerate that delay
  release_age_hours="$(get_release_age_hours "$release_repo" "$client_release")"
  if [ -n "$release_age_hours" ] && [ "$release_age_hours" -lt "${SOURCE_GRACE_HOURS:-24}" ]; then
    warn "source image $source_image not found, release $client_release is ${release_age_hours}h old - waiting for upstream"
    exit 0
  fi
  fail "source image $source_image not found (release $client_release is ${release_age_hours:-?}h old)"
fi

target_image="$TARGET_IMAGE:$client_release"
echo "check target image: $target_image"
if docker manifest inspect "$target_image" >/dev/null 2>&1; then
  if [ "${FORCE:-false}" == "true" ]; then
    echo "target image already exists, rebuilding anyway (force)"
  else
    echo "target image already exists!"
    exit 0
  fi
fi

{
  echo "client_release=$client_release"
  echo "source_image=$source_image"
  echo "target_image=$target_image"
  echo "need_build=true"
} >> "${GITHUB_OUTPUT:-/dev/stdout}"
