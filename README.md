# RVC-v2-UI RunPod Serverless Implementation

This is a RunPod serverless implementation of [RVC-v2-UI](https://github.com/neda-ai/RVC-v2-UI), allowing you to run voice conversion tasks through a serverless API endpoint.

## Features

-   Serverless voice conversion using RVC v2 models
-   Support for custom model downloads
-   Flexible audio input/output handling
-   GPU acceleration via RunPod infrastructure

## API Usage

### Endpoint Input Format

```json
{
    "input": {
        "protect": 0.5, // Protection rate (0-0.5)
        "f0_method": "rmvpe", // Pitch detection algorithm (rmvpe or mangio-crepe)
        "rvc_model": "CUSTOM", // Model name to use
        "index_rate": 1, // Index rate (0-1)
        "input_audio": "https://example.com/audio.mp3", // URL to input audio file
        "pitch_change": 8, // Pitch change in semitones
        "rms_mix_rate": 1, // RMS mix rate (0-1)
        "filter_radius": 1, // Filter radius (0-7)
        "output_format": "mp3", // Output audio format
        "custom_rvc_model_download_url": "https://example.com/model.zip" // Optional: URL to download custom model
    }
}
```

### Parameters

| Parameter                     | Type    | Description                                                | Default  |
| ----------------------------- | ------- | ---------------------------------------------------------- | -------- |
| protect                       | float   | Protection rate to preserve original voice characteristics | 0.33     |
| f0_method                     | string  | Pitch detection algorithm ('rmvpe' or 'mangio-crepe')      | 'rmvpe'  |
| rvc_model                     | string  | Name of the RVC model to use                               | Required |
| index_rate                    | float   | Index rate for voice conversion (0-1)                      | 0.5      |
| input_audio                   | string  | URL to the input audio file                                | Required |
| pitch_change                  | integer | Pitch change in semitones                                  | 0        |
| rms_mix_rate                  | float   | RMS mix rate (0-1)                                         | 0.25     |
| filter_radius                 | integer | Filter radius (0-7)                                        | 3        |
| output_format                 | string  | Output audio format ('wav' or 'mp3')                       | 'wav'    |
| custom_rvc_model_download_url | string  | URL to download custom RVC model (optional)                | null     |

### Response Format

Success Response:

```json
{
    "output": {
        "audio_data": "<binary_audio_data>",
        "output_format": "mp3"
    }
}
```

Error Response:

```json
{
    "error": "Error message description"
}
```

## Development

### Prerequisites

-   Docker
-   NVIDIA GPU with CUDA support
-   RunPod account

### Building the Docker Image

1. Clone this repository:

```bash
git clone <repository-url>
cd <repository-name>
```

2. Build the Docker image:

```bash
docker build -t your-image-name .
```

### Local Testing

You can test the implementation locally by running:

```bash
docker run --gpus all -p 7860:7860 your-image-name
```

### Deployment to RunPod

1. Push your Docker image to a container registry
2. Create a new RunPod serverless endpoint using your image
3. Use the provided endpoint URL to make API calls

## Implementation Details

The implementation consists of three main components:

1. **RVC-v2-UI**: The core voice conversion system
2. **RunPod Handler**: Interfaces between RunPod and RVC-v2-UI
3. **Gradio API Client**: Manages communication between the handler and RVC-v2-UI

The system flow is as follows:

1. RunPod receives the API request
2. The handler downloads any specified custom model
3. The input audio is downloaded
4. Voice conversion is performed via the Gradio API
5. The converted audio is returned

## Notes

-   The system uses the Gradio API internally to communicate with RVC-v2-UI
-   Custom models are downloaded and cached during runtime
-   Temporary files are automatically cleaned up after processing
-   GPU acceleration is automatically utilized when available

## License

This project is licensed under the same terms as the original RVC-v2-UI project.

## Acknowledgments

-   Original RVC-v2-UI project by [PseudoRAM](https://github.com/PseudoRAM/RVC-v2-UI)
-   RunPod for serverless GPU infrastructure
