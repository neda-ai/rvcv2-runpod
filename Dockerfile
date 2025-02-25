FROM nvidia/cuda:11.8.0-cudnn8-runtime-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1

# Install system dependencies
RUN apt-get update && apt-get install -y \
    python3.9 \
    python3-pip \
    git \
    ffmpeg \
    libsndfile1 \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Clone RVC v2 repository
RUN git clone https://github.com/PseudoRAM/RVC-v2-UI.git /app/RVC-v2-UI

# Install dependencies
WORKDIR /app/RVC-v2-UI
RUN pip3 install --no-cache-dir -r requirements.txt

# Download required models
RUN python3 src/download_models.py

# Create model cache directory
RUN mkdir -p /root/.cache/huggingface
ENV MODEL_CACHE_DIR=/root/.cache/huggingface

# Copy handler code
COPY rp_handler.py /app/

# Set working directory back to /app
WORKDIR /app

# Set up entrypoint
CMD ["python3", "-u", "rp_handler.py"] 