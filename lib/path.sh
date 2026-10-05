# shellcheck shell=sh
# path.sh — a small POSIX sh library of path helpers: source it, then call its functions.
#
#   . lib/path.sh
#   path_join /usr/ local bin    # -> /usr/local/bin
#   path_ext archive.tar.gz      # -> gz
#   path_stem /tmp/report.csv    # -> report
#   path_is_abs /etc             # status 0

# path_join PART... — join with single slashes
path_join() {
  _out=''
  for _p in "$@"; do
    [ -z "$_p" ] && continue
    if [ -z "$_out" ]; then _out=$_p
    else _out="${_out%/}/${_p#/}"
    fi
  done
  printf '%s\n' "$_out"
}

# path_ext PATH — the last extension, without the dot ("" when there is none)
path_ext() {
  _b=${1##*/}
  case $_b in
    .*.*|[!.]*.*) printf '%s\n' "${_b##*.}" ;;
    *) printf '\n' ;;
  esac
}

# path_stem PATH — the file name without its last extension
path_stem() {
  _b=${1##*/}
  _e=$(path_ext "$1")
  printf '%s\n' "${_b%."$_e"}"
}

# path_is_abs PATH — true for an absolute path
path_is_abs() {
  case $1 in /*) return 0 ;; *) return 1 ;; esac
}
