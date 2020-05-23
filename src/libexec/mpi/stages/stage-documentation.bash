#!/usr/bin/env bash
set -euo pipefail

# Main Function
#
# Returns the exit code of the last command executed or 0 otherwise.
function main()
{
  # kind: documentation
  documentationType="${DOCUMENTATION_TYPE:-none}"
  # - hugo
  if [ "${documentationType}" == "hugo" ]; then
    HUGO_TARGET=${HUGO_TARGET:-${ARTIFACT_DIR}/docs}
    @mpi action hugo-build
  # - default
  else
    @mpi.log_message "INFO" "not generating a documentation, type [${documentationType}] is not supported!"
  fi

  # kind: changelog
  # - release notes
  if [ "$NCI_COMMIT_REF_TYPE" == "tag" ]; then
    # generate changelog
    @mpi action changelog-generate --ref="$NCI_COMMIT_REF_NAME" --output="${TMP_DIR}/changelog"

    # notification
    # - discord
    if [ -n "$RELEASE_WEBHOOK_DISCORD" ]; then
      @mpi.discord.send_webhook "RELEASE_WEBHOOK_DISCORD" "Releasebot" "$(<${TMP_DIR}/changelog)"
    fi
    # - rocketchat
    if [ -n "$RELEASE_WEBHOOK_ROCKETCHAT" ]; then
      @mpi.rocketchat.send_webhook "RELEASE_WEBHOOK_ROCKETCHAT" "Releasebot" "$(<${TMP_DIR}/changelog)"
    fi
  fi
}

# entrypoint
main "$@"
