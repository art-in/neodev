#!/bin/bash

# This script creates a pipe, into which containers are supposed to write paths
# to open in host OS (e.g. browser links), and starts listening on that pipe in
# background process.
#
# Since real pipes are impossible to bind across macos and linux, it uses regular
# file as a queue - reading last line. File will be removed automatically by OS,
# as part of periodic /tmp cleanup.
#
# All started containers bind to same pipe. Only one listener is started on host.
# After started with first container, listener will run indefinitely.
#
# To monitor the listener process use: ps aux | grep browser_pipe

PIPE="/tmp/browser_pipe"

# create pipe if missing
if [ ! -f "$PIPE" ]; then
    touch "$PIPE"
    chmod 666 "$PIPE"
fi

# start listener if not already running
if ! pgrep -f "tail -F -n 0 -f $PIPE" > /dev/null; then
    echo "Starting browser pipe listener..."
    {
      # read last line added after this process started.
      # -F flag tracks the filename, not the descriptor. so when system
      # clears the file from tmp/, this script continues with new file
      tail -F -n 0 -f "$PIPE" | while read -r line; do
        # echo "[DEBUG] Received message in pipe: $line"
        [[ -n "$line" ]] && open "$line"
      done
    } &>/dev/null &
    disown
else
    echo "Browser pipe listener is already running."
fi

