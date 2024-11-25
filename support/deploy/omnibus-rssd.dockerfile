# This Dockerfile builds a containerized environment for the surveilr CLI to generate and serve 
# SQLite databases (RSSDs) based on source files from a specified repository. It uses a multi-stage 
# build to keep the final image lightweight by separating the build and runtime dependencies. 
# The setup employs Traefik as a reverse proxy to expose each RSSD as a unique URL endpoint, allowing 
# each database to be accessed independently.

# ---- Overview ----
# - Stage 1: "builder" stage:
#   - Installs the surveilr CLI and required dependencies.
#   - Clones the www.surveilr.com repository and searches for `package.sql.ts` files within specified directories.
#   - For each `package.sql.ts` file found, generates a corresponding RSSD (SQLite database) and saves it in `/rssd`.
#   - Generates an index file (`/rssd/index.tsv`) listing each RSSD with its relative path, filename, port, and fields (`expose_endpoint`, `package_sql`)
#     indicating if it should be exposed to the proxy and containing the full relative path of `package.sql.ts`.
#   - Creates a provenance file (`/rssd/provenance.tsv`) containing the `git_repo` field with the full Git clone URL.
#
# - Stage 2: "runtime" stage:
#   - Installs only essential runtime dependencies, keeping the final image minimal.
#   - Copies the RSSDs, index file, and provenance file from Stage 1.
#   - At runtime, generates a Traefik configuration file (`/rssd/traefik.toml`) based on `index.tsv`, respecting the `PROXY_BASE_PATH` 
#     environment variable. Only RSSDs with `expose_endpoint` set to 1 are configured as routed services in Traefik.
#   - Generates an `index.html` file that lists all RSSD endpoints, setting it as the default page for the root URL.
#   - Exposes the `/rssd` directory as a volume, allowing external access for debugging and inspection.
#   - Sets the `SQLPAGE_SITE_PREFIX` environment variable for each `surveilr web-ui` instance to match the Traefik endpoint.
#
# ---- Usage ----
# - Build the image: `docker build -t surveilr-rssd .`
# - Run the container: `docker run -p 80:80 -v $(pwd)/rssd:/rssd surveilr-rssd`
# - To set a custom base path, use the `PROXY_BASE_PATH` environment variable:
#   `docker run -p 80:80 -e PROXY_BASE_PATH=/example -v $(pwd)/rssd:/rssd surveilr-rssd`
# 
# ---- Pushing to GitHub Container Registry ----
# To store this image in the GitHub container registry for the `surveilr` organization:
# 1. Build the Docker image and tag it for GitHub Container Registry:
#    `docker build -t ghcr.io/surveilr/www.surveilr.com-omnibus-RSSD:latest .`
# 2. Push the image to GitHub Container Registry:
#    `docker push ghcr.io/surveilr/www.surveilr.com-omnibus-RSSD:latest`

# Stage 1: Build and Preparation
FROM debian:latest AS builder

# Install necessary build tools and dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    deno

# Install surveilr using the provided script
WORKDIR /usr/local/bin
RUN curl -sL https://raw.githubusercontent.com/opsfolio/releases.opsfolio.com/main/surveilr/install.sh | sh

# Clone the www.surveilr.com repository
WORKDIR /app
RUN git clone https://github.com/surveilr/www.surveilr.com.git

# Create a provenance file with the Git clone URL in /rssd/provenance.tsv
RUN mkdir -p /rssd && \
    echo -e "git_repo\tfull_clone_url" > /rssd/provenance.tsv && \
    echo -e "git_repo\thttps://github.com/surveilr/www.surveilr.com.git" >> /rssd/provenance.tsv

# Create an index file with a header for RSSDs
RUN echo -e "expose_endpoint\trelative_path\trssd_name\tport\tpackage_sql" > /rssd/index.tsv

# Find directories containing `eg.surveilr.com-prepare.ts`, prepare RSSDs dependencies
RUN RSSD_SRC_PATH=($(find /app/www.surveilr.com -type f -name "eg.surveilr.com-prepare.ts" -exec dirname {} \;)) && \   
    for path in "${RSSD_SRC_PATH[@]}"; do \
      relative_path=$(echo "$path" | sed 's#/app/www.surveilr.com/##'); \
      package_sql="${relative_path}/package.sql.ts"; \
      cd "$path" && \
      deno run -A  ./eg.surveilr.com-prepare.ts && \    
    done

# Find directories containing `package.sql.ts`, build RSSDs, save in /rssd, and update index file with port number
RUN RSSD_SRC_PATH=($(find /app/www.surveilr.com -type f -name "package.sql.ts" -exec dirname {} \;)) && \
    port=9000 && \
    for path in "${RSSD_SRC_PATH[@]}"; do \
      # Convert path to a format suitable for the RSSD filename and get package_sql
      relative_path=$(echo "$path" | sed 's#/app/www.surveilr.com/##'); \
      rssd_name=$(echo "$relative_path" | sed 's#/#-#g').sqlite.db; \
      package_sql="${relative_path}/package.sql.ts"; \
      cd "$path" && \
      surveilr shell ./package.sql.ts -d /rssd/$rssd_name && \
      # Set expose_endpoint to 1 by default
      echo -e "1\t${relative_path}\t${rssd_name}\t${port}\t${package_sql}" >> /rssd/index.tsv; \
      port=$((port+1)); \
    done

 # Find directories containing `eg.surveilr.com-finalize.ts`, finalize RSSDs dependencies
RUN RSSD_SRC_PATH=($(find /app/www.surveilr.com -type f -name "eg.surveilr.com-finalize.ts" -exec dirname {} \;)) && \   
    for path in "${RSSD_SRC_PATH[@]}"; do \
      relative_path=$(echo "$path" | sed 's#/app/www.surveilr.com/##'); \
      package_sql="${relative_path}/package.sql.ts"; \
      cd "$path" && \
      deno run -A  ./eg.surveilr.com-finalize.ts && \    
    done
   
# Stage 2: Final Runtime Image
FROM debian:latest

# Install only essential runtime dependencies: traefik and surveilr binary
RUN apt-get update && apt-get install -y traefik && rm -rf /var/lib/apt/lists/*

# Set the PROXY_BASE_PATH environment variable with default value '/'
ENV PROXY_BASE_PATH="/"

# Copy surveilr binary from builder stage
COPY --from=builder /usr/local/bin/surveilr /usr/local/bin/surveilr

# Copy prepared RSSDs, index file, and provenance file from builder stage
COPY --from=builder /rssd /rssd

# Expose the /rssd directory for external access and debugging
VOLUME /rssd

# Generate the index.html file listing all endpoints
RUN repo_url=$(awk -F'\t' 'NR==2 {print $2}' /rssd/provenance.tsv) && \
    echo "<h1>RSSDs in ${repo_url}</h1><ul>" > /rssd/index.html && \
    tail -n +2 /rssd/index.tsv | while IFS=$'\t' read -r expose_endpoint relative_path rssd_name port package_sql; do \
      if [ "$PROXY_BASE_PATH" != "/" ] && [ "${PROXY_BASE_PATH: -1}" != "/" ]; then \
        PROXY_BASE_PATH="${PROXY_BASE_PATH}/"; \
      fi; \
      full_path="${PROXY_BASE_PATH}${relative_path}"; \
      if [ "$expose_endpoint" -eq "1" ]; then \
        echo "<li><a href=\"${full_path}\">${package_sql}</a></li>" >> /rssd/index.html; \
      else \
        echo "<li>${package_sql} (not exposed)</li>" >> /rssd/index.html; \
      fi; \
    done && \
    echo "</ul>" >> /rssd/index.html

# Expose the main Traefik port and starting port range for surveilr services
EXPOSE 80 9000-9099

# Final command to generate the Traefik configuration at runtime, then launch surveilr and Traefik
CMD ( \
      # Generate Traefik configuration at runtime to respect PROXY_BASE_PATH set at startup
      echo "entryPoints:\n  web:\n    address: :80\n" > /rssd/traefik.toml && \
      echo "http:\n  routers:\n" >> /rssd/traefik.toml && \
      echo "  index:\n    entryPoints:\n      - web\n    rule: \"PathPrefix(\\\"/\\\")\"\n    service: index-service\n" >> /rssd/traefik.toml && \
      echo "  services:\n    index-service:\n      loadBalancer:\n        servers:\n          - url: \"file:///rssd/index.html\"\n" >> /rssd/traefik.toml && \
      tail -n +2 /rssd/index.tsv | while IFS=$'\t' read -r expose_endpoint relative_path rssd_name port package_sql; do \
        if [ "$expose_endpoint" -eq "1" ]; then \
          name=$(basename "$rssd_name" .sqlite.db); \
          # Ensure PROXY_BASE_PATH ends with a slash if not root '/'
          if [ "$PROXY_BASE_PATH" != "/" ] && [ "${PROXY_BASE_PATH: -1}" != "/" ]; then \
            PROXY_BASE_PATH="${PROXY_BASE_PATH}/"; \
          fi; \
          full_path="${PROXY_BASE_PATH}${relative_path}"; \
          echo "  ${name}:\n    entryPoints:\n      - web\n    service: ${name}-service\n    rule: \"PathPrefix(\\\"${full_path}\\\")\"\n" >> /rssd/traefik.toml && \
          echo "  services:\n    ${name}-service:\n      loadBalancer:\n        servers:\n          - url: \"http://localhost:${port}\"\n" >> /rssd/traefik.toml; \
        fi; \
      done && \
      # Start surveilr web servers for each RSSD with SQLPAGE_SITE_PREFIX set to the endpoint path
      tail -n +2 /rssd/index.tsv | while IFS=$'\t' read -r expose_endpoint relative_path rssd_name port package_sql; do \
        if [ "$expose_endpoint" -eq "1" ]; then \
          if [ "$PROXY_BASE_PATH" != "/" ] && [ "${PROXY_BASE_PATH: -1}" != "/" ]; then \
            PROXY_BASE_PATH="${PROXY_BASE_PATH}/"; \
          fi; \
          SQLPAGE_SITE_PREFIX="${PROXY_BASE_PATH}${relative_path}" \
          surveilr web-ui -d "/rssd/$rssd_name" --port ${port} & \
        fi; \
      done \
    ) && traefik --configFile=/rssd/traefik.toml
