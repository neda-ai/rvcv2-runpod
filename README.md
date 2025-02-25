# RVC v2 RunPod Serverless

This project provides a RunPod serverless endpoint for running RVC (Retrieval-based Voice Conversion) v2. It's based on the [RVC-v2-UI](https://github.com/PseudoRAM/RVC-v2-UI) project.

## Features

-   Voice conversion using RVC v2
-   Serverless deployment on RunPod
-   GPU acceleration support

## Setup

1. Build the Docker image:

    ```bash
    docker build -t your-image-name .
    ```

2. Push to your container registry:

    ```bash
    docker push your-registry/your-image-name
    ```

3. Deploy on RunPod serverless platform:
    - Create a new serverless endpoint
    - Use your pushed Docker image
    - Configure the desired GPU type

## API Usage

The endpoint accepts POST requests with the following format:

```json
{
    "input": {
        "audio_file": "base64_encoded_audio",
        "model_path": "path_to_model",
        "transpose": 0,
        "f0_method": "harvest",
        "index_rate": 0.5,
        "protect_voiceless": 0.33,
        "filter_radius": 3
    }
}
```

Response format:

```json
{
    "output": {
        "converted_audio": "base64_encoded_audio"
    }
}
```

## Environment Variables

-   `CUDA_VISIBLE_DEVICES`: GPU device to use
-   `MODEL_CACHE_DIR`: Directory to cache downloaded models

## License

See the [LICENSE](LICENSE) file for details.
