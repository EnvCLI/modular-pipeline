#!/usr/bin/env bash
set -euo pipefail

# Public: Sends a rocketchat webhook
#
# RocketChat Incoming Webhook Script
#  class Script {
#    process_incoming_request({ request }) {
#      console.log(request.content);
#      return {
#        content:{
#          text: request.content.text
#         }
#      };
#      return {
#         error: {
#           success: false,
#           message: 'Error example'
#         }
#       };
#    }
#  }
#
# Examples
#
#   @mpi.rocketchat.send_message "ROCKETCHAT_WEBHOOK" "Releasebot" "Released version x.x.x"
#
# Returns the exit code of the last command executed or 0 otherwise.
@mpi.rocketchat.send_message()
{
  declare endpointVar="${1:-}" senderName="${2:-}" message="${3:-}"

  # prepare body
  httpPayload=$(cat <<EOF
{
  "username": "${senderName}",
  "text": "${message}"
}
EOF
  )

  @mpi.run_command curl \
    --silent \
    --output /dev/null \
    -X POST \
    -H 'Content-type: application/json' \
    --data "${httpPayload}" \
    "${!endpointVar}"
}
