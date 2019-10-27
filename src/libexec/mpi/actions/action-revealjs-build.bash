#!/usr/bin/env bash
set -euo pipefail

# Main Function
#
# Returns the exit code of the last command executed or 0 otherwise.
function main()
{
  # build the presentation
  @mpi.log_message "INFO" "Building presentation ..."

  # # https://asciidoctor.org/docs/asciidoctor-revealjs/#reveal-js-options
  @mpi.container_command asciidoctor-revealjs \
    --backend revealjs \
    --destination-dir ${ARTIFACT_DIR} \
    -a revealjsdir=https://cdnjs.cloudflare.com/ajax/libs/reveal.js/3.8.0 \
    -a revealjs_progress=true \
    -a revealjs_showSlideNumber=true \
    -a revealjs_history=true \
    -a revealjs_showNotes=true \
    --timings \
    presentation.adoc
}

# entrypoint
main "$@"
