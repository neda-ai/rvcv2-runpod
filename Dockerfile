FROM nvidia/cuda:11.8.0-cudnn8-runtime-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1

# Install system dependencies
RUN apt-get update && apt-get install -y \
    python3.10 \
    python3-pip \
    git \
    ffmpeg \
    libsndfile1 \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Clone RVC v2 repository
RUN git clone https://github.com/PseudoRAM/RVC-v2-UI.git /app/RVC-v2-UI

# Copy requirements and install Python dependencies
COPY requirements.txt .
RUN pip3 install --no-cache-dir -r requirements.txt

# Copy handler code
COPY handler.py .

# Create model cache directory
RUN mkdir -p /root/.cache/huggingface
ENV MODEL_CACHE_DIR=/root/.cache/huggingface

# Set up entrypoint
CMD ["python3", "-u", "handler.py"] 