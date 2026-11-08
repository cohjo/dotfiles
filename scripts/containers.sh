#!/usr/bin/env sh
set -eu
if [ "$(uname -s)" != Darwin ]; then
  printf '%s\n' 'On Linux, manage the native Docker Engine with your host service/rootless setup.' >&2
  exit 1
fi
case "${1:-status}" in
  start) colima start --cpu "${COLIMA_CPU:-2}" --memory "${COLIMA_MEMORY:-2}" --disk "${COLIMA_DISK:-40}" ;;
  stop) colima stop ;;
  status) colima status ;;
  *) printf '%s\n' 'Usage: containers.sh start|stop|status' >&2; exit 1 ;;
esac
