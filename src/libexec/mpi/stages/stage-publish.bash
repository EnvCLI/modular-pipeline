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
  # publishType: containerregistry
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

  # publishType: nexus
  if [[ ${PUBLISH_TYPE} == "nexus" ]]; then
    if [[ ${PROJECT_TYPE} == "java" ]]; then
      @mpi action java-publish
    fi
  fi

  # publishType: bintray
  if [[ ${PUBLISH_TYPE} == "bintray" ]]; then
    if [[ ${PROJECT_TYPE} == "java" ]]; then
      @mpi action java-publish
    fi
  fi

  # publishType: artifactory
  if [[ ${PUBLISH_TYPE} == "artifactory" ]]; then
    if [[ ${PROJECT_TYPE} == "java" ]]; then
      @mpi action java-publish
    fi
  fi

  # github
  if [[ ${PUBLISH_TYPE} == "github" ]]; then
    # upload artifacts

    @mpi.log_message "WARN" "publishType GitHub is not supported yet!"
    return 0
  fi

  # kind: changelog
  # - release notes
  if [ "$NCI_COMMIT_REF_TYPE" == "tag" ]; then
    # generate changelog
    # @mpi action changelog-generate --ref="$NCI_COMMIT_REF_NAME" --output="${TMP_DIR}/changelog.md"

    # release notification
    # - github
    if [ -n "${GITHUB_TOKEN:-}" ] && [ -n "${GITHUB_REPOSITORY:-}" ]; then
      CHANGELOG_CONFIG_FILE="${CHANGELOG_CONFIG_FILE_DISCORD:-$TMP_DIR/changelog/publish-release-github.yml}" @mpi action changelog-generate --ref="$NCI_COMMIT_REF_NAME" --output="${TMP_DIR}/changelog-github"
      @mpi.github.create_release "$GITHUB_REPOSITORY" "$NCI_COMMIT_REF_NAME" "$(<${TMP_DIR}/changelog-github)"
    fi
    # - discord
    if [ -n "${RELEASE_WEBHOOK_DISCORD:-}" ]; then
      RELEASE_WEBHOOK_DISCORD_SENDERNAME="${RELEASE_WEBHOOK_DISCORD_SENDERNAME:-Releasebot}"
      CHANGELOG_CONFIG_FILE="${CHANGELOG_CONFIG_FILE_DISCORD:-$TMP_DIR/changelog/publish-release-discord.yml}" @mpi action changelog-generate --ref="$NCI_COMMIT_REF_NAME" --output="${TMP_DIR}/changelog-discord"
      @mpi.discord.send_message "RELEASE_WEBHOOK_DISCORD" "$RELEASE_WEBHOOK_DISCORD_SENDERNAME" "$(<${TMP_DIR}/changelog-discord)"
    fi
    # - rocketchat
    if [ -n "${RELEASE_WEBHOOK_ROCKETCHAT:-}" ]; then
      RELEASE_WEBHOOK_ROCKETCHAT_SENDERNAME="${RELEASE_WEBHOOK_ROCKETCHAT_SENDERNAME:-Releasebot}"
      @mpi.rocketchat.send_message "RELEASE_WEBHOOK_ROCKETCHAT" "$RELEASE_WEBHOOK_ROCKETCHAT_SENDERNAME" "$(<${TMP_DIR}/changelog.md)"
    fi
  fi
}

# entrypoint
main "$@"
