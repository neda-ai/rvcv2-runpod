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
    google-perftools \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /

RUN echo "Installing RVC-v2-UI"

# Clone RVC v2 repository
RUN git clone https://github.com/neda-ai/RVC-v2-UI.git /RVC-v2-UI

# Install RVC-v2-UI dependencies
WORKDIR /RVC-v2-UI
RUN pip3 install --no-cache-dir -r requirements.txt

# Download required models
RUN python3 src/download_models.py

# Set up RunPod handler
WORKDIR /
COPY requirements.txt rp_handler.py start.sh ./
RUN chmod +x start.sh

# Install RunPod handler dependencies
RUN pip3 install --no-cache-dir -r requirements.txt

# Create directory for temporary files
RUN mkdir -p /tmp

# Set up entrypoint
CMD [ "/start.sh" ]