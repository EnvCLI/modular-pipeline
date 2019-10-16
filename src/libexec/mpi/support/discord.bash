#!/usr/bin/env bash
set -euo pipefail

# Public: Sends a discord message to a channel via webhook
#
# This will send a discord message to a specified channel.
#
# Examples
#
#   @mpi.discord.send_webhook "DISCORD_RELEASE_WEBHOOK" "Releasebot" "Released version x.x.x"
#
# Returns the exit code of the last command executed or 0 otherwise.
@mpi.discord.send_webhook()
{
  declare endpointVar="${1:-}" senderName="${2:-}" message="${3:-}"

  @mpi.run_command curl \
    -H "Content-Type: application/json" \
    -X POST \
    -d '{"username": "${senderName}", "content": "${message}"}' \
    ${!endpointVar}
}
