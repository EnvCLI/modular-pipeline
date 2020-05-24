#!/usr/bin/env bash
set -euo pipefail

# Public: Sends a discord message to a channel via webhook
#
# This will send a discord message to a specified channel.
# Documentation: https://birdie0.github.io/discord-webhooks-guide/discord_webhook.html
#
# Examples
#
#   @mpi.discord.send_message "DISCORD_RELEASE_WEBHOOK" "Releasebot" "Released version x.x.x"
#
# Returns the exit code of the last command executed or 0 otherwise.
@mpi.discord.send_message()
{
  declare endpointVar="${1:-}" senderName="${2:-}" message="${3:-}"

  messageDump=$(mktemp -d ${TMP_DIR}/discord.XXXXXXXXX)
  @mpi.log_message "INFO" "sending message to discord webhook [logfile:$messageDump]!"

  # post body
  httpPayload=$(cat <<EOF
{
  "username": "${senderName}",
  "content": "${message}"
}
EOF
  )

  # request
  @mpi.run_command curl \
    --no-progress-meter \
    --output /dev/null \
    -H "Content-Type: application/json" \
    -X POST \
    -d "$httpPayload" \
    --trace-asci $messageDump \
    "${!endpointVar}"
}
