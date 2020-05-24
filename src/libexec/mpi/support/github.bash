#!/usr/bin/env bash
set -euo pipefail

# Public: Creates a github release
#
# Examples
#
#   @mpi.github.create_release
#
# Returns the exit code of the last command executed or 0 otherwise.
@mpi.github.create_release()
{
  declare repository="${1:-}" version="${2:-}" message="${3:-}"

  # release notes
  contentEscaped=$(jq -aRs . <<< "$message")

  # isPrerelease?
  isPreRelease="true"
  if [[ "$version" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    isPreRelease="false"
  fi

  # prepare body
  httpPayload=$(cat <<EOF
{
  "tag_name": "$version",
  "name": "$version",
  "body": $contentEscaped,
  "draft": false,
  "prerelease": $isPreRelease
}
EOF
  )
  @mpi.log_message "INFO" "creating github release: $httpPayload!"

  @mpi.run_command curl \
    --fail \
    --no-progress-meter \
    --output /dev/null \
    -H "Content-Type: application/json" \
    -H "Accept: application/vnd.github.v3+json" \
    -H "Authorization: token ${GITHUB_TOKEN}" \
    -X POST \
    -d "$httpPayload" \
    "https://api.github.com/repos/${repository}/releases"
}
