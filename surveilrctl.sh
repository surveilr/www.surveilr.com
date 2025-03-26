#!/usr/bin/env bash
set -e

# surveilrctl installation script
# Usage: SURVEILR_HOST=xyz curl -sL surveilr.com/surveilrctl.sh | bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

GITHUB_REPO="surveilr/surveilrctl"
LATEST_RELEASE_URL="https://api.github.com/repos/$GITHUB_REPO/releases/latest"

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                surveilrctl Installation Script              ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"

# Check if SURVEILR_HOST is set
if [ -z "$SURVEILR_HOST" ]; then
    echo -e "${YELLOW}Warning: SURVEILR_HOST environment variable is not set.${NC}"
    echo -e "${YELLOW}You'll need to manually run setup after installation.${NC}"
    echo -e "${YELLOW}Example: surveilrctl setup --uri https://your-host${NC}"
    echo ""
fi

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

for cmd in curl grep cut sed; do
    if ! command_exists $cmd; then
        echo -e "${RED}Error: Required command '$cmd' not found.${NC}"
        exit 1
    fi
done

# Detect OS and architecture
OS="$(uname -s | tr '[:upper:]' '[:lower:]')"
ARCH="$(uname -m)"

case $OS in
    linux)
        TARGET="x86_64-unknown-linux-gnu"
        BINARY_NAME="surveilrctl"
        ;;
    darwin)
        TARGET="x86_64-apple-darwin"
        if [ "$ARCH" = "arm64" ]; then
            echo -e "${YELLOW}Note: Running on Apple Silicon. Using x86_64 binary with Rosetta.${NC}"
            if ! pgrep -q oahd; then
                echo -e "${YELLOW}Rosetta 2 does not appear to be installed.${NC}"
                echo -e "${YELLOW}Installing Rosetta 2 (requires admin privileges)${NC}"
                softwareupdate --install-rosetta --agree-to-license
            fi
        fi
        BINARY_NAME="surveilrctl"
        ;;
    *)
        echo -e "${RED}Error: Unsupported operating system: $OS${NC}"
        echo -e "${RED}This script supports only Linux and macOS.${NC}"
        echo -e "${RED}For Windows, please use: winget install surveilrctl${NC}"
        exit 1
        ;;
esac

echo -e "${GREEN}Detected OS: $OS${NC}"
echo -e "${GREEN}Detected arch: $ARCH${NC}"
echo -e "${GREEN}Using target: $TARGET${NC}"

# Get the latest release version from GitHub
echo -e "${BLUE}Fetching latest release information...${NC}"
if ! LATEST_RELEASE=$(curl -s $LATEST_RELEASE_URL); then
    echo -e "${RED}Error: Failed to fetch latest release information.${NC}"
    exit 1
fi

VERSION=$(echo "$LATEST_RELEASE" | grep '"tag_name":' | cut -d '"' -f 4 | sed 's/^v//')
if [ -z "$VERSION" ]; then
    echo -e "${RED}Error: Could not determine latest version.${NC}"
    exit 1
fi

echo -e "${GREEN}Latest version: $VERSION${NC}"

if [ "$OS" = "linux" ]; then
    DOWNLOAD_URL="https://github.com/$GITHUB_REPO/releases/download/v$VERSION/surveilrctl_${VERSION}_${TARGET}.tar.gz"
    ARCHIVE_NAME="surveilrctl_${VERSION}_${TARGET}.tar.gz"
    EXTRACT_CMD="tar -xzf"
else
    DOWNLOAD_URL="https://github.com/$GITHUB_REPO/releases/download/v$VERSION/surveilrctl_${VERSION}_${TARGET}.zip"
    ARCHIVE_NAME="surveilrctl_${VERSION}_${TARGET}.zip"
    EXTRACT_CMD="unzip -o"
fi

TMP_DIR=$(mktemp -d)
cd "$TMP_DIR"

echo -e "${BLUE}Downloading $ARCHIVE_NAME...${NC}"
if ! curl -sL -o "$ARCHIVE_NAME" "$DOWNLOAD_URL"; then
    echo -e "${RED}Error: Failed to download $ARCHIVE_NAME${NC}"
    exit 1
fi

echo -e "${BLUE}Extracting archive...${NC}"
if ! $EXTRACT_CMD "$ARCHIVE_NAME"; then
    echo -e "${RED}Error: Failed to extract archive.${NC}"
    exit 1
fi

INSTALL_DIR="/usr/local/bin"
if [ ! -w "$INSTALL_DIR" ]; then
    echo -e "${YELLOW}Need elevated privileges to install to $INSTALL_DIR${NC}"
    if command_exists sudo; then
        echo -e "${BLUE}Installing with sudo...${NC}"
        sudo install -m 755 "$BINARY_NAME" "$INSTALL_DIR/"
    else
        echo -e "${RED}Error: Cannot write to $INSTALL_DIR and sudo is not available.${NC}"
        echo -e "${YELLOW}You can manually move the binary to a location in your PATH:${NC}"
        echo -e "${YELLOW}  mv $TMP_DIR/$BINARY_NAME ~/.local/bin/${NC}"
        exit 1
    fi
else
    install -m 755 "$BINARY_NAME" "$INSTALL_DIR/"
fi

cd - > /dev/null
rm -rf "$TMP_DIR"

echo -e "${GREEN}✓ surveilrctl has been installed to $INSTALL_DIR/$BINARY_NAME${NC}"

# setup if SURVEILR_HOST is provided
if [ -n "$SURVEILR_HOST" ]; then
    echo -e "${BLUE}Running initial setup with host: $SURVEILR_HOST${NC}"
    
    # check if we need sudo for the setup
    if command_exists sudo; then
        SETUP_CMD="sudo surveilrctl setup --uri $SURVEILR_HOST"
    else
        SETUP_CMD="surveilrctl setup --uri $SURVEILR_HOST"
    fi
    
    echo -e "${BLUE}Executing: $SETUP_CMD${NC}"
    echo -e "${YELLOW}This may require your password for sudo.${NC}"
    
    if eval "$SETUP_CMD"; then
        echo -e "${GREEN}✓ Setup completed successfully!${NC}"
    else
        echo -e "${RED}Setup failed. You may need to run it manually:${NC}"
        echo -e "${YELLOW}  sudo surveilrctl setup --uri $SURVEILR_HOST${NC}"
    fi
else
    echo -e "${BLUE}To complete setup, run:${NC}"
    echo -e "${YELLOW}  sudo surveilrctl setup --uri https://your-surveilr-host${NC}"
fi

echo ""
echo -e "${GREEN}Installation complete!${NC}"