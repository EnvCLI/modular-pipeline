#!/usr/bin/env bash

# Public: Prints the stack trace at the point of the call.
#
# If supplied, the `skip_callers` argument should be a positive integer (i.e. 1
# or greater) to remove the caller (and possibly the caller's caller, and so on)
# from the resulting stack trace.
#
# Arguments:
#   skip_callers:  The number of callers to skip over when printing the stack
#
# Examples
#
#   @mpi.print_stack_trace
#
# Returns the exit code of the last command executed or 0 otherwise.
@mpi.print_stack_trace() {
  local skip_callers="$1"
  local result=0
  local i

  if [[ -n "$skip_callers" && ! "$skip_callers" =~ ^[1-9][0-9]*$ ]]; then
    printf '%s argument %s not a positive integer; printing full stack\n' \
      "$FUNCNAME" "'$skip_callers'" >&2
    result=1
  elif [[ "$skip_callers" -ge "${#FUNCNAME[@]}" ]]; then
    printf '%s argument %d exceeds stack size %d; printing full stack\n' \
      "$FUNCNAME" "$skip_callers" "$((${#FUNCNAME[@]} - 1))" >&2
    result=1
  fi

  if [[ "$result" -ne '0' ]]; then
    skip_callers=0
  fi

  for ((i=$skip_callers + 1; i != ${#FUNCNAME[@]}; ++i)); do
    printf '  %s:%s %s\n' "${BASH_SOURCE[$i]}" "${BASH_LINENO[$((i-1))]}" \
      "${FUNCNAME[$i]}"
  done
  return "$result"
}
