# Dockerized Nginx with PageSpeed Optimization

This project provides a **Dockerized Nginx** with **PageSpeed** and performance-enhancing modules for high-speed web serving. It includes essential optimizations like Brotli compression, HTTP/2, gzip compression, and Redis support, with multiple additional Nginx modules for enhanced functionality.

## Features
- **Optimized Nginx build** for performance and security.
- Includes essential Nginx modules:
  - Brotli compression
  - HTTP/2 support
  - Gzip compression
  - Redis support
  - Caching with ngx_cache_purge
- **PageSpeed module** to speed up web pages.
- **Multi-stage Docker build** for clean and lean images.
- **Pre-configured** for easy integration with common web apps.
- Published on Docker Hub for fast deployment.

## Usage

To use this Docker image in your project:

1. **Pull the image from Docker Hub**:
   ```bash
   docker pull snowden/nginx-pagespeed:latest
   ```

2. **Run the container**:
   ```bash
   docker run -d -p 80:80 -p 8080:8080 --name nginx-pagespeed snowden/nginx-pagespeed:latest
   ```

3. **Configure your Nginx setup** by modifying the `nginx.conf` and `sites-enabled` files in the `config/` folder.

## Configuration

- Nginx configurations can be found in the `/etc/nginx` directory inside the container. You can customize `nginx.conf`, `conf.d/`, `include/`, and `sites-enabled/` to suit your needs.
- PageSpeed optimizations are enabled by default, and you can further tweak settings by editing `/etc/nginx/pagespeed`.

## Health Check

This container includes a built-in health check that ensures Nginx is running correctly:

```bash
HEALTHCHECK --interval=5s --timeout=5s CMD curl -I http://127.0.0.1:8080/health || exit 1
```

## Contributing

We welcome contributions! Feel free to fork this repository, create issues, and submit pull requests. Make sure to follow the coding standards and include tests with your contributions.

## License

This project is licensed under the MIT License.

## Docker Hub Versioning

For automated versioning and tracking, the image is tagged as `latest` on Docker Hub. You can specify specific versions like `v1.0`, `v1.1`, etc., based on your project requirements.

## Links

- [Docker Hub Repository](https://hub.docker.com/r/snowden/nginx-pagespeed)

---

Feel free to modify any sections as needed!
