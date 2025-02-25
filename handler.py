import os
import sys
import base64
import runpod
import torch
import numpy as np
import soundfile as sf
from io import BytesIO

# Add RVC-v2-UI to Python path
sys.path.append('/app/RVC-v2-UI')

from infer.modules.vc.modules import VC
from infer.modules.vc.utils import load_audio

# Initialize the VC model
vc = VC()

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
        input_data = event["input"]
        audio_base64 = input_data["audio_file"]
        model_path = input_data["model_path"]
        transpose = input_data.get("transpose", 0)
        f0_method = input_data.get("f0_method", "harvest")
        index_rate = float(input_data.get("index_rate", 0.5))
        protect_voiceless = float(input_data.get("protect_voiceless", 0.33))
        filter_radius = int(input_data.get("filter_radius", 3))

        # Decode input audio
        audio, sr = decode_audio(audio_base64)
        
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