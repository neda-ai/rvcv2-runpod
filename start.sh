#!/usr/bin/env bash

# Use libtcmalloc for better memory management
TCMALLOC="$(ldconfig -p | grep -Po "libtcmalloc.so.\d" | head -n 1)"
export LD_PRELOAD="${TCMALLOC}"

# Verify GPU is available
echo "rvcv2-runpod: Checking for GPU availability..."
if command -v nvidia-smi &> /dev/null; then
    nvidia-smi
    echo "rvcv2-runpod: GPU detected"
else
    echo "rvcv2-runpod: WARNING - nvidia-smi not found. GPU may not be available!"
fi

# Verify PyTorch can see the GPU
echo "rvcv2-runpod: Checking PyTorch GPU support..."
python3 -c "import torch; print('CUDA available:', torch.cuda.is_available()); print('CUDA device count:', torch.cuda.device_count()); print('CUDA device name:', torch.cuda.get_device_name(0) if torch.cuda.is_available() else 'N/A')"

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
  if [[ "$line" == *"Running on local URL"* ]]; then
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