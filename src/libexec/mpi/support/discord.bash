#!/usr/bin/env bash
set -euo pipefail

# Public: Sends a discord message to a channel via webhook
#
# This will send a discord message to a specified channel.
# Documentation: https://birdie0.github.io/discord-webhooks-guide/discord_webhook.html
#
# Examples
#
#   @mpi.discord.send_webhook "DISCORD_RELEASE_WEBHOOK" "Releasebot" "Released version x.x.x"
#
# Returns the exit code of the last command executed or 0 otherwise.
@mpi.discord.send_webhook()
{
  declare endpointVar="${1:-}" senderName="${2:-}" message="${3:-}"

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
    --silent \
    --output /dev/null \
    -H "Content-Type: application/json" \
    -X POST \
    -d "$httpPayload" \
    "${!endpointVar}"
}
