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

  # TODO: check tag for vX.X.X / vX.X.X-alpha.X / etc. to detect prereleases

  # prepare body
  httpPayload=$(cat <<EOF
{
  "tag_name": "$version",
  "target_commitish": "$version",
  "name": "$version",
  "body": $contentEscaped,
  "draft": false,
  "prerelease": false
}
EOF
  )

  @mpi.run_command curl \
    --fail \
    --no-progress-meter \
    --output /dev/null \
    -H "Content-Type: application/json" \
    -X POST \
    --data "$(GENERATE_POST_BODY)" \
    "https://api.github.com/repos/${repository}/releases?access_token=${GITHUB_TOKEN}"
}
