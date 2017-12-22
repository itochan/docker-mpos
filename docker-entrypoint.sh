#!/bin/bash

if ! [ -e index.php ]; then
  echo >&2 "MPOS not found in $PWD - copying now..."
  if [ "$(ls -A)" ]; then
    echo >&2 "WARNING: $PWD is not empty - press Ctrl+C now if this is an error!"
    ( set -x; ls -A; sleep 10 )
  fi
  tar cf - --one-file-system -C /usr/src/mpos . | tar xf -
  echo >&2 "Complete! MPOS has been successfully copied to $PWD"
fi

exec "$@"
