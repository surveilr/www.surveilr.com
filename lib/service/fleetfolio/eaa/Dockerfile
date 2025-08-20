# syntax=docker/dockerfile:1.7
#
# Fleetfolio EAA - Nightingale + Runme
# Builds a container that runs the Fleetfolio EAA "Pentest Lite" Runme runbook
# and writes artifacts to /var/fleetfolio (mount this as a volume).
#
# Base image can be overridden at build time:
#   docker build --build-arg NIGHTINGALE_IMAGE=ghcr.io/rajanagori/nightingale:latest -t fleetfolio-eaa:latest .

ARG NIGHTINGALE_IMAGE=ghcr.io/rajanagori/nightingale:latest
FROM ${NIGHTINGALE_IMAGE}

LABEL org.opencontainers.image.title="Fleetfolio EAA - Pentest Lite"
LABEL org.opencontainers.image.description="OWASP Nightingale with Runme preinstalled, executing the Fleetfolio EAA runbook."
LABEL org.opencontainers.image.source="https://github.com/RAJANAGORI/Nightingale"

SHELL ["/bin/bash", "-lc"]

# Install Runme using the official script
RUN set -euo pipefail &&     curl -fsSL https://raw.githubusercontent.com/stateful/runme/main/install.sh | bash -s -- -b /usr/local/bin &&     runme version || true

# Default environment (can be overridden at runtime via docker-compose or docker run -e ...)
ENV RUNBOOK_PATH="/opt/fleetfolio/eaa-pentest-lite.runme.md"     FLEETFOLIO_EAA_HOME=""     FLEETFOLIO_EAA_DOMAINS=""     FLEETFOLIO_EAA_IP_RANGES=""     FLEETFOLIO_EAA_KEY_URLS=""     FLEETFOLIO_EAA_EXCLUDES=""     FLEETFOLIO_EAA_RATE_LIMIT="200"     FLEETFOLIO_EAA_CONCURRENCY="50"     FLEETFOLIO_EAA_NAABU_PORTS="top-100"     FLEETFOLIO_EAA_NUCLEI_TEMPLATES="cves,default"

# Copy the runbook into the image
# Ensure fleetfolio-eaa-pentest-lite.runme.md exists in the build context (same folder as Dockerfile)
COPY fleetfolio-eaa-pentest-lite.runme.md ${RUNBOOK_PATH}

# Ensure evidence root exists and is declared as a volume for persistence
RUN mkdir -p /var/fleetfolio
VOLUME ["/var/fleetfolio"]

# Helpful working dir for interactive use
WORKDIR /workspace

# Default command: run the runbook on container start
# - If you prefer to drop into a shell after execution, append '&& bash' or override the command in compose.
CMD ["/bin/bash", "-lc", "runme run ${RUNBOOK_PATH}"]
