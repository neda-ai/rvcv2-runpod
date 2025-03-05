#!/usr/bin/env bash

# Use libtcmalloc for better memory management
TCMALLOC="$(ldconfig -p | grep -Po "libtcmalloc.so.\d" | head -n 1)"
export LD_PRELOAD="${TCMALLOC}"

# Create a named pipe for capturing output
PIPE=$(mktemp -u)
mkfifo $PIPE

# Start RVC-v2-UI and redirect output to both the pipe and stdout
echo "rvcv2-runpod: Starting RVC-v2-UI"
python3 /RVC-v2-UI/src/webui.py > >(tee $PIPE) &

# Wait for the server to be ready
echo "rvcv2-runpod: Waiting for RVC-v2-UI to be ready..."
while read line < $PIPE; do
  echo "$line"
  if [[ "$line" == *"To create a public link"* ]]; then
    echo "rvcv2-runpod: RVC-v2-UI is ready"
    break
  fi
done

# Start Runpod Handler
echo "rvcv2-runpod: Starting Runpod Handler"
python3 -u /rp_handler.py &

# Clean up the pipe
rm $PIPE

# Keep the script running until all background processes are done
wait