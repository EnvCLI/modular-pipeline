#!/usr/bin/env bash
set -euo pipefail

# Main Function
#
# Environment:
#  BINTRAY_ORGANZATION: The organisation the package should be published in, can be identical to the username.
#  BINTRAY_REPOSITORY: The repository within the org/user.
#  BINTRAY_PACKAGE: The package that gets published in a repository within a org.
#  BINTRAY_USERNAME: Username used to authenticate with bintray.
#  BINTRAY_TOKEN: Access token for the provided username.
#
# Returns the exit code of the last command executed or 0 otherwise.
function main()
{
  # configuration
  ARTIFACT_DIR=${ARTIFACT_DIR:-dist}

  # publish artifacts
  for file in $ARTIFACT_DIR/*
  do
    TARGET_PATH=$BINTRAY_PACKAGE/$NCI_COMMIT_REF_NAME/$(basename -- "$file")
    echo "--> Publishing $file to $TARGET_PATH ..."

    curl --upload-file "$file" -u$BINTRAY_USERNAME:$BINTRAY_TOKEN https://api.bintray.com/content/$BINTRAY_ORGANZATION/$BINTRAY_REPOSITORY/$BINTRAY_PACKAGE/$NCI_COMMIT_REF_NAME/$TARGET_PATH
  done
}

# entrypoint
main "$@"
