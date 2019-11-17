#!/usr/bin/env bash

@mpi.run_script() {
  local cmd_path="$1"
  shift

  local interpreter
  read -r interpreter < "$cmd_path"

  if [[ "${interpreter:0:2}" != '#!' ]]; then
    echo "The first line of %s does not contain #!/path/to/interpreter.\n" "$cmd_path" >&2
    return 1
  fi

  interpreter="${interpreter%$'\r'}"
  interpreter="${interpreter:2}"
  interpreter="${interpreter#*/env }"
  interpreter="${interpreter##*/}"
  interpreter="${interpreter%% *}"

  if [[ "$interpreter" == 'bash' || "$interpreter" == 'sh' ]]; then
    @mpi.run_command . "$cmd_path" "$@"
  elif [[ "$interpreter" == 'python3' ]]; then
    @mpi.run_command "$cmd_path" "$@"
  else
    echo "Could not parse interpreter from first line of $cmd_path.\n" >&2
    return 1
  fi
}
