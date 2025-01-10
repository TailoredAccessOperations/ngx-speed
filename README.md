# Nginx with Pagespeed docker image

This project provides an optimized Nginx Docker image with the PageSpeed module and other useful extensions.

## Features

-   Optimized Nginx for high performance.
-   PageSpeed enabled for automatic web page optimization.
-   Multi-stage docker builds for minimal image size
-   Modular Nginx configuration.
-   Properly documented.
-   Easy to set up and run with docker compose.
-   Automatic TLS certificate generation with self-signed configuration.
-   Proper environment variable support.
 
## Usage

1.  Clone the repository.
2.  Customize environment variables in `.env` file using `.env-example` as a template.
3.  Build and run the docker container using:
   ```bash
   docker-compose up --build -d
   ```
4.  Access the web server at `http://localhost` or `https://localhost`.

## Advanced Customisation
1. Modify the configurations in `config` folder and rebuild the docker images using `docker-compose up --build -d`
2.  Modify the `scripts` for custom docker entrypoint and startup functionalities.

## Important Notice
  * Self-signed certificates are generated when the container starts for the first time.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

