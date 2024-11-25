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

Start using `surveilr` by following the quick guide below:

- **macOS and Linux:**

  - Install `surveilr` in desired path by running any of the following commands:

    ```bash
    # install in current path
    $ curl -sL https://raw.githubusercontent.com/opsfolio/releases.opsfolio.com/main/surveilr/install.sh | bash

    # Install globally
    $ curl -sL https://raw.githubusercontent.com/opsfolio/releases.opsfolio.com/main/surveilr/install.sh | SURVEILR_HOME="$HOME/bin" bash

    # install in preferred path
    $ curl -sL https://raw.githubusercontent.com/opsfolio/releases.opsfolio.com/main/surveilr/install.sh | SURVEILR_HOME="/path/to/directory" bash
    ```

  - [Verify installation](/docs/core/installation#verify-installation)

- **Windows:**

  - Install `surveilr` by executing the following command in **windows
    powershell** terminal

    ```bash
    $ irm https://raw.githubusercontent.com/opsfolio/releases.opsfolio.com/refs/heads/main/surveilr/install.ps1 | iex
    ```

  - [Verify installation](/docs/core/installation#verify-installation)

### Still Got Questions ?

Check out our [FAQ](https://www.surveilr.com/#faqs)
