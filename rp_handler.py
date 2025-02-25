import os
import sys
import base64
import runpod
import torch
import numpy as np
import soundfile as sf
import requests
from io import BytesIO

# Add RVC-v2-UI to Python path
sys.path.append('/app/RVC-v2-UI')

from infer.modules.vc.modules import VC
from infer.modules.vc.utils import load_audio

# Initialize the VC model
vc = VC()

def download_audio_from_url(url):
    """Download audio file from URL."""
    response = requests.get(url)
    response.raise_for_status()  # Raise an exception for bad status codes
    audio_bytes = BytesIO(response.content)
    audio, sr = sf.read(audio_bytes)
    return audio, sr

def decode_audio(audio_base64):
    """Decode base64 audio to numpy array."""
    audio_bytes = base64.b64decode(audio_base64)
    audio_io = BytesIO(audio_bytes)
    audio, sr = sf.read(audio_io)
    return audio, sr

def encode_audio(audio, sr):
    """Encode numpy array audio to base64."""
    audio_io = BytesIO()
    sf.write(audio_io, audio, sr, format='WAV')
    audio_bytes = audio_io.getvalue()
    return base64.b64encode(audio_bytes).decode('utf-8')

def handler(event):
    """
    RunPod handler function for voice conversion.
    """
    try:
        # Get input parameters
        input = event["input"]
        audio_input = input.get("audio_file") or input.get("audio_url")
        if not audio_input:
            raise ValueError("Either audio_file (base64) or audio_url must be provided")
            
        model_path = input["model_path"]
        transpose = input.get("transpose", 0)
        f0_method = input.get("f0_method", "harvest")
        index_rate = float(input.get("index_rate", 0.5))
        protect_voiceless = float(input.get("protect_voiceless", 0.33))
        filter_radius = int(input.get("filter_radius", 3))

        # Decode input audio
        if "audio_url" in input:
            audio, sr = download_audio_from_url(audio_input)
        else:
            audio, sr = decode_audio(audio_input)
        
        # Load the model if not already loaded
        if not hasattr(handler, 'current_model') or handler.current_model != model_path:
            vc.get_vc(model_path)
            handler.current_model = model_path

        # Process audio
        audio_opt = vc.vc_single(
            audio, 
            transpose, 
            f0_method=f0_method,
            index_rate=index_rate,
            protect=protect_voiceless,
            filter_radius=filter_radius
        )[0]

        # Encode output audio
        output_base64 = encode_audio(audio_opt, sr)

        return {
            "output": {
                "converted_audio": output_base64
            }
        }

    except Exception as e:
        return {
            "error": str(e)
        }

if __name__ == "__main__":
    runpod.serverless.start({"handler": handler}) 