#!/usr/bin/env bash
set -euo pipefail

# Main Function
#
# Environment:
#  none
#
# Returns the exit code of the last command executed or 0 otherwise.
function main()
{
  # container registry
  if [[ ${PUBLISH_TYPE} == "containerregistry" ]]; then
    if test -f "${TMP_DIR}/container-image/main.tar"; then
      # import image
      @mpi.log_message "INFO" "publishing container image from ${TMP_DIR}/container-image/main.tar"
      @mpi.run_command docker load -i "${TMP_DIR}/container-image/main.tar"

      # publish
      @mpi action container-push
    else
      @mpi.log_message "INFO" "can't publish into container registry ..."
      exit 1
    fi
  fi

  # bintray
  if [[ ${PUBLISH_TYPE} == "bintray" ]]; then
    # for cli and libraries, TODO: add filter later
    @mpi.log_message "INFO" "publishing bintray artifacts from dist/"
    @mpi action bintray-publish
  fi

  # github
  if [[ ${PUBLISH_TYPE} == "github" ]]; then
    # create github release

    # upload artifacts

    @mpi.log_message "WARN" "publishType GitHub is not supported yet!"
    return 0
  fi

  # release notes
  if [ "$NCI_COMMIT_REF_TYPE" == "tag" ]; then
    # generate changelog
    @mpi action changelog-generate --ref=$NCI_COMMIT_REF_NAME --output=${TMP_DIR}/changelog

    # notification
    # - discord
    if [ -n "$PUBLISH_WEBHOOK_DISCORD" ]; then
      @mpi.discord.send_webhook "PUBLISH_WEBHOOK_DISCORD" "Releasebot" "$(<${TMP_DIR}/changelog)"
    fi
    # - rocketchat
    if [ -n "$PUBLISH_WEBHOOK_ROCKETCHAT" ]; then
      @mpi.rocketchat.send_webhook "PUBLISH_WEBHOOK_ROCKETCHAT" "Releasebot" "$(<${TMP_DIR}/changelog)"
    fi
  fi
}

# entrypoint
main "$@"
