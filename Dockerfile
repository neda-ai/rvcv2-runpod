FROM nvidia/cuda:12.4.1-cudnn-devel-ubuntu22.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=on

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3.10 \
    python3-pip \
    python3-dev \
    ffmpeg \
    git \
    wget \
    curl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
RUN echo "install git"
RUN apt install -y git
# Create a working directory
WORKDIR /app

# Copy requirements and install dependencies
COPY requirements.txt .
RUN export PATH="/usr/bin:$PATH"
RUN pip3 install --no-cache-dir -r requirements.txt

COPY src/download_models.py /app/src/download_models.py

# Download required models
RUN python3 src/download_models.py

# Copy the application code
COPY . .

# Set the entrypoint
ENTRYPOINT ["python3", "rp_handler.py"] 
