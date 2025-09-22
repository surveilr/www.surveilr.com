# syntax=docker/dockerfile:1
FROM kalilinux/kali-last-release

ARG DEBIAN_FRONTEND=noninteractive

# ------------------------------------------------------------------------------
# 0) Make HTTPS work for apt: install ca-certificates via HTTP, then switch to HTTPS
# ------------------------------------------------------------------------------
RUN set -eux; \
    sed -i 's|https://http.kali.org|http://http.kali.org|' /etc/apt/sources.list || true; \
    apt-get clean; \
    apt-get update; \
    apt-get install -y --no-install-recommends ca-certificates; \
    sed -i 's|http://http.kali.org|https://http.kali.org|' /etc/apt/sources.list; \
    apt-get update --fix-missing; \
    apt-get -y full-upgrade

# ------------------------------------------------------------------------------
# 1) Base packages, Kali/Debian tools, and common deps
# ------------------------------------------------------------------------------
    RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
      sudo ca-certificates curl wget git zsh bash coreutils \
      build-essential gcc jq python3 python3-pip python3-setuptools python3-wheel \
      whatweb nmap openssl \
      subfinder dnsx httpx-toolkit naabu nuclei dirsearch \
      wafw00f testssl.sh paramspider \
      golang-go \
    && apt-get clean && rm -rf /var/lib/apt/lists/*; \
    \
    git clone https://github.com/s0md3v/Corsy.git /opt/eaa/Corsy; \
    pip3 install -r /opt/eaa/Corsy/requirements.txt --break-system-packages; \
    \
    git clone https://github.com/r0oth3x49/ghauri.git /opt/eaa/ghauri; \
    cd /opt/eaa/ghauri && python3 setup.py install

# ------------------------------------------------------------------------------
# 2) Create non-root user (for Homebrew) with passwordless sudo
# ------------------------------------------------------------------------------
RUN set -eux; \
    useradd -ms /bin/zsh -u 1000 kali; \
    echo "kali ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/90-kali; \
    chmod 0440 /etc/sudoers.d/90-kali

USER kali
ENV HOME=/home/kali
WORKDIR /home/kali

# ------------------------------------------------------------------------------
# 3) Bootstrap Homebrew manually (avoids installer’s sudo/git ref locking issues)
# ------------------------------------------------------------------------------
ENV HOMEBREW_NO_INSTALL_CLEANUP=1 \
    HOMEBREW_NO_ANALYTICS=1 \
    HOMEBREW_COLOR=1 \
    NONINTERACTIVE=1

# Prepare linuxbrew home owned by kali
USER root
RUN set -eux; \
    mkdir -p /home/linuxbrew/.linuxbrew; \
    chown -R kali:kali /home/linuxbrew
USER kali

# Clone Homebrew repo and wire up brew
RUN set -eux; \
    git clone --depth 1 https://github.com/Homebrew/brew /home/linuxbrew/.linuxbrew/Homebrew; \
    mkdir -p /home/linuxbrew/.linuxbrew/bin; \
    ln -sf ../Homebrew/bin/brew /home/linuxbrew/.linuxbrew/bin/brew; \
    echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> "$HOME/.zshrc"; \
    /home/linuxbrew/.linuxbrew/bin/brew update --force --quiet; \
    /home/linuxbrew/.linuxbrew/bin/brew --version

# Make brew available in PATH for subsequent layers
ENV PATH="/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:${PATH}"

# Basic brew health (gcc used by some formulae)
RUN set -eux; brew install gcc

# ------------------------------------------------------------------------------
# 4) Install Runme via Homebrew
# ------------------------------------------------------------------------------
RUN set -eux; brew install runme rustscan

# ------------------------------------------------------------------------------
# 5) Go-based tools (latest) to /usr/local/bin
# ------------------------------------------------------------------------------
USER root
ENV GOBIN=/usr/local/bin
RUN set -eux; \
    go install github.com/projectdiscovery/katana/cmd/katana@latest; \
    go install github.com/projectdiscovery/tlsx/cmd/tlsx@latest; \
    go install -v github.com/PentestPad/subzy@latest
    

# Make Homebrew available to root shells too (nice for interactive sessions)
RUN echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> /root/.zshrc

# ------------------------------------------------------------------------------
# 6) Install Surveiler tool
# ------------------------------------------------------------------------------
RUN set -eux; \
    wget https://github.com/opsfolio/releases.opsfolio.com/releases/download/2.2.0/resource-surveillance_2.2.0_x86_64-unknown-linux-gnu.tar.gz && \
    tar -xvf resource-surveillance_2.2.0_x86_64-unknown-linux-gnu.tar.gz && \
    mv surveilr /usr/local/bin

# ------------------------------------------------------------------------------
# 7) Copy .env file from build context into /opt/eaa
# ------------------------------------------------------------------------------
COPY .env /opt/eaa/.env

# ------------------------------------------------------------------------------
# 8) Add the runbook and prep nuclei templates
# ------------------------------------------------------------------------------
WORKDIR /opt/eaa/

# Ensure the sessions directory exists in the container
RUN mkdir -p /opt/eaa/sessions/opsfolio

COPY fleetfolio-eaa-pentest-lite.runme.md /opt/eaa/
RUN set -eux; nuclei -update -silent || true; nuclei -update-templates -silent || true

# ------------------------------------------------------------------------------
# 9) Check the contents of /opt/eaa directory during build
# ------------------------------------------------------------------------------
RUN ls -al /opt/eaa/

# ------------------------------------------------------------------------------
# 10) Default Command to run on container start (explicitly use bash)
# ------------------------------------------------------------------------------
WORKDIR /opt/eaa/
CMD [ "bash", "-c", "source /opt/eaa/.env && runme run --filename='fleetfolio-eaa-pentest-lite.runme.md' --all -y" ]
