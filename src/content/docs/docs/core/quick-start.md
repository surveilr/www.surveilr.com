---
title: Quick Start
description: instructions on the installation of `surveilr`
---

:::tip[Tip]

- **System Requirements**: While `surveilr` can run on low-performing systems,
  we recommend at least a dual-core processor, 2GB of RAM, and 8GB of available
  disk space for optimal performance.

:::

## How to install Resource Surveillance & Integration Engine (`surveilr`) for Critical Systems

Start using `surveilr` Resource Surveillance by following the quick guide below:

### 📦 Package Managers (Recommended)

- **Ubuntu/Debian:**

  ```bash
  # Ubuntu (Jammy)
  $ wget https://github.com/surveilr/packages/releases/latest/download/surveilr_jammy.deb
  $ sudo dpkg -i surveilr_jammy.deb

  # Debian (Bookworm)
  $ wget https://github.com/surveilr/packages/releases/latest/download/surveilr_bookworm.deb
  $ sudo dpkg -i surveilr_bookworm.deb
  ```

- **macOS (Homebrew):**

  ```bash
  $ brew tap surveilr/tap && brew install surveilr
  ```

- **Windows:**

  ```powershell
  # Recommended: Use installation script
  $ irm https://raw.githubusercontent.com/surveilr/packages/refs/heads/main/scripts/install.ps1 | iex
  ```

### 📜 Alternative Installation Methods

- **macOS and Linux Scripts:**

  ```bash
  # install in current path
  $ curl -sL https://raw.githubusercontent.com/surveilr/packages/main/scripts/install.sh | bash

  # Install globally
  $ curl -sL https://raw.githubusercontent.com/surveilr/packages/main/scripts/install.sh | SURVEILR_HOME="$HOME/bin" bash

  # install in preferred path
  $ curl -sL https://raw.githubusercontent.com/surveilr/packages/main/scripts/install.sh | SURVEILR_HOME="/path/to/directory" bash
  ```

- **Direct Download:**

  Visit [GitHub Releases](https://github.com/surveilr/packages/releases) to download pre-built binaries for your operating system.

- [Verify installation](/docs/core/installation#verify-installation)

### Still Got Questions ?

Check out our [FAQ](https://www.surveilr.com/#faqs)
