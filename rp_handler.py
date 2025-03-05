import runpod
import os
import time
from gradio_client import Client, handle_file
import requests
from urllib.parse import urlparse

def download_file(url):
    """Download a file from a URL to a temporary location"""
    response = requests.get(url)
    filename = os.path.basename(urlparse(url).path)
    temp_path = f"/tmp/{filename}"
    with open(temp_path, "wb") as f:
        f.write(response.content)
    return temp_path

def handler(event):
    """Handle the RunPod event by interfacing with the Gradio API"""
    try:
        # Get input parameters
        input_params = event["input"]
        
        # Initialize Gradio client
        client = Client("http://127.0.0.1:7860/")
        
        # If there's a custom model URL, download it first
        if input_params.get("custom_rvc_model_download_url"):
            model_url = input_params["custom_rvc_model_download_url"]
            model_name = input_params["rvc_model"]
            
            try:
            # Download and set up the custom model
                result = client.predict(
                    model_url,
                    model_name,
                    api_name="/download_online_model"
                )
                print(f"Model download result: {result}")
            except Exception as e:
                return {"error": str(e)}
            # Update models list
            client.predict(api_name="/update_models_list")
            
            # Wait a bit for the model to be loaded
            time.sleep(2)
        
        # Download the input audio file
        input_audio_path = download_file(input_params["input_audio"])
        
        # Perform voice conversion
        result = client.predict(
            input_audio = handle_file(input_audio_path),  # input_audio
            rvc_model = input_params["rvc_model"],  # rvc_model
            pitch = input_params.get("pitch_change", 0),  # pitch
            f0_method = input_params.get("f0_method", "rmvpe"),  # f0_method
            index_rate = input_params.get("index_rate", 0.5),  # index_rate
            filter_radius = input_params.get("filter_radius", 3),  # filter_radius
            rms_mix_rate = input_params.get("rms_mix_rate", 0.25),  # rms_mix_rate
            protect = input_params.get("protect", 0.33),  # protect
            api_name="/voice_conversion"
        )
        
        # Read the output file and convert to base64
        with open(result, "rb") as f:
            output_data = f.read()
            
        # Clean up temporary files
        os.remove(input_audio_path)
        os.remove(result)
        
        return {
            "output": {
                "audio_data": output_data,
                "output_format": input_params.get("output_format", "wav")
            }
        }
        
    except Exception as e:
        return {"error": str(e)}

runpod.serverless.start({"handler": handler})