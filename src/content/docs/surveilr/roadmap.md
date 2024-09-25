---
title: Resource Surveillance Roadmap
description: surveilr roadmap
---
# Introduction

Welcome to the page for the `surveilr` Roadmap! Our goal with this part is to give our users an open picture of our ongoing work and planned features. In-depth details on our next weekly releases as well as our longer-term goals and concepts may be found here. Our intention is to keep you updated and involved as we work to add new features and capabilities to `surveilr`. We'll be updating this plan every week so you always have the most recent details regarding our development path.


## Weekly Releases (Next 4 Weeks)

### Week 1 (September 9 - 13, 2024)
  1. **Integrate Deno into `surveilr`**
     - [ ] The command `surveilr run ...` will function similarly to `deno run ...`, for example, `surveilr run -A my.ts`.
      - [ ] If permitted by the `deno_core` crate, `surveilr run` should also accept scripts passed via STDIN.
      - [ ] Access to all `surveilr` functions should be enabled as Deno TypeScript functions through foreign function interface (FFI) imports.
           - [ ] In any TypeScript file, it should be possible to invoke `surveilr` functions, such as `surveilr.xyz(...)`, where `xyz` is the Rust FFI.
      - [ ] All functions from Rusqlite and RSSD for managing SQLite files should be accessible under the namespace `sqlite.xyz()`, where `sqlite` stands for `rusqlite` and `xyz()` represents any permissible method from Rusqlite.
      - [ ] Subsequently, we will introduce the `--extend my.ts` argument to all commands/subcommands, allowing the inclusion of one or more `--extend` flags. This will load `my.ts` through `deno_core`, enabling the definition of SQLite functions within Deno.

### Week 2 (September 16 - September 20, 2024)
1. **DuckDB 1.1 Integration**: Introduce a feature that activates the `--duckdb` flag, enabling the use of the embedded Rust-based DuckDB for orchestration as an alternative to `rusqlite`. DuckDB provides enhanced orchestration capabilities, including the ability to attach the RSSD and use SQLite for storage purposes, while employing DuckDB for orchestration functions.
2. **FUSE interface to browse and work with uniform resources**: 
      All rows from the `uniform_resource` table (and associated tables) should be accessible through a FUSE file system as follows:

      ```
      surveilr mount /x/y/z
      ```

      Upon execution, the following file systems should be available:

      - `/x/y/z/uniform_resource`
      - `/x/y/z/*` where * represents each related `ur_*` and `uniform_resource_*` table

      `FUSE` enables the entries in `uniform_resource` and related tables to be accessed as filesystem files, allowing standard Linux and Windows/MacOS commands to operate on the content.

### Week 3 (September 23 - September 27, 2024)
1. **RSSD Schema Migration**
    - Utilize Atlas with `surveilr` SQL notebooks to create migrations for RSSDs, ensuring smooth transitions and updates.

2. **Non-Interactive Authentication for Microsoft 365 Integration**
 - [ ] Non-Interactive Authentication
   - [ ] Automatic retrieval of access and refresh tokens.
   - [ ] Secure cache for refresh tokens.
   - [ ] Command: `surveilr ingest imap microsft-365 -i="<CLIENT_ID>" -s="<CLIENT SECRET>" -t="<TENANT_ID>"`
 - [ ] Interactive Authentication
   - [ ] Require either `-m auth-code` or `-m device-code` to initiate interactive authentication.


3. **Implement VFS Strategy Using rclone for Multi-source File Acquisition**
   -  [ ] Develop a new `surveilr ingest vfs` command that utilizes rclone to source files from various locations (e.g., S3, SFTP, local).
   -  [ ] Implement `surveilr vfs` as an alias for rclone commands, enabling virtual file system operations without requiring separate rclone installation.
   -  [ ] Ensure `surveilr ingest vfs` stages files from multiple locations (clouds, file systems, WebDAV, etc.) using rclone and then processes the staged files with `surveilr ingest files`.
   -  [ ] Coordinate with the RSIE team to document the multi-source acquisition strategy into the RSIE pattern specification.


### October

1. **Remote Automated Osquery Setup for `surveilr`**
    - Implement a remote automated setup for Osquery within `surveilr` using [`xxh`](https://github.com/xxh/xxh), enabling streamlined deployment and configuration.

2. **Create an NPM Package for Installing `surveilr`**

   - **Objective:**
   To streamline the installation process of `surveilr` in JavaScript projects by developing a custom NPM Package that integrates seamlessly with existing NPM workflows.

   - **Description:**
   We aim to create a custom NPM Package designed to facilitate the installation and integration of `surveilr` into JavaScript projects. This package will simplify the setup process, ensuring that developers can easily incorporate `surveilr` into their existing workflows without encountering common installation hurdles.

   - **Key Features:**
     - **Seamless Integration:** Ensure the package integrates smoothly with existing NPM workflows.
     - **Simplified Installation:** Streamline the setup process for developers incorporating `surveilr`.
     - **Comprehensive Documentation:** Provide detailed documentation to guide users through the installation and integration process.

   - **Tasks:**
     1. **Package Design:**
        - Define the package structure and dependencies.
        - Plan for compatibility with various JavaScript frameworks and environments.
        
     2. **Development:**
        - Implement the core functionalities required for the `surveilr` installation.
        - Develop scripts to automate common setup tasks.
        
     3. **Testing:**
        - Perform thorough testing to ensure reliability and compatibility.
        - Collect feedback from beta testers and make necessary adjustments.

     4. **Documentation:**
        - Create detailed documentation covering installation steps, usage instructions, and troubleshooting.
        - Include example projects and code snippets to demonstrate usage.

     5. **Release:**
        - Prepare the package for release on the NPM registry.
        - Announce the release and provide support channels for user feedback and issues.

3. **Create a Maven Plugin for Installing `surveilr`**

   - **Objective:**
   To simplify the installation process of `surveilr` in Maven projects by developing a Maven plugin that automatically handles all necessary dependencies and configurations.

   - **Description:**
   We aim to create a Maven plugin designed to facilitate the installation and integration of `surveilr` into Maven projects. This plugin will streamline the setup process, ensuring that developers can easily incorporate `surveilr` into their existing workflows without encountering common installation hurdles.

   - **Key Features:**
     - **Automatic Dependency Management:** Handle all necessary dependencies required for `surveilr` integration.
     - **Simplified Configuration:** Automatically configure settings needed for `surveilr` within Maven projects.
     - **Comprehensive Documentation:** Provide detailed documentation to guide users through the installation and integration process.

   - **Tasks**
     1. **Plugin Design:**
        - Define the plugin structure and dependencies.
        - Plan for compatibility with various Maven project setups.
        
     2. **Development:**
        - Implement the core functionalities required for `surveilr` installation.
        - Develop automation scripts for dependency management and configuration setup.
        
     3. **Testing:**
        - Perform thorough testing to ensure reliability and compatibility.
        - Collect feedback from beta testers and make necessary adjustments.

     4. **Documentation:**
        - Create detailed documentation covering installation steps, usage instructions, and troubleshooting.
        - Include example projects and configuration snippets to demonstrate usage.

     5. **Release:**
        - Prepare the plugin for release on the Maven Central repository.
        - Announce the release and provide support channels for user feedback and issues.


4. **Windows `winget` Installation Support**

   1. Create Manifest File
      - **Description**: Develop a manifest file required by WinGet to facilitate the installation of `surveilr` on Windows machines.
      - **Tasks**:
        - Define the metadata and configuration settings for the `surveilr` package.
        - Ensure the manifest file complies with WinGet specifications.

   2. Add Uncompressed `surveilr.exe` to Release Assets
      - **Description**: Upload the uncompressed `surveilr.exe` executable to the release assets in the GitHub repository.
      - **Tasks**:
        - Ensure the latest version of `surveilr.exe` is uncompressed and available in the release assets.
        - Verify the executable's integrity and functionality.

   3. Add CI Action to Update Manifest File Upon New Release
      - **Description**: Implement a Continuous Integration (CI) action to automatically update the manifest file whenever a new release of `surveilr` is published.
      - **Tasks**:
        - Set up a CI workflow to trigger on new releases.
        - Update the manifest file with the latest release information.
        - Test the CI action to ensure it performs the update correctly.

5. **Add gitSupplier feature to `surveilr udi pgp`**

   - **Objective:**
   To enhance `surveilr`'s capabilities by integrating the gitSupplier feature from udi-pgp-sqld, enabling it to monitor and analyze git commit logs from both local and remote repositories.

   - **Description:**
   The gitSupplier feature will be integrated into `surveilr`, supporting two modes for ingesting git commit logs: Local Mode and Remote Mode. This integration will allow `surveilr` to monitor and analyze git commit logs from specified local git repository directory paths and remote GitHub repository URLs, providing a versatile tool for development and operations teams.

   - **Modes**
     - **Local Mode:**
       - Ingests git commit logs from a specified local git repository directory path.
     - **Remote Mode:**
       - Ingests git commit logs from a specified remote GitHub repository URL.

   - **Purpose:**
   The integration of the gitSupplier feature will enhance `surveilr`'s capabilities by enabling it to monitor and analyze git commit logs from both local and remote repositories. This will provide a more versatile tool for development and operations teams, allowing for comprehensive source control surveillance.

   - **Expected Benefits:**
     - **Enhanced Monitoring Capabilities:** Ability to monitor git commit logs from both local and remote repositories.
     - **Increased Flexibility:** More options for managing source control surveillance.
     - **Seamless Tracking:** Ability to track changes and activity across different environments.


6. **Add Regex-Based Filtering for Attachment Extraction in `surveilr`**

   - **Objective:**
   To enhance the flexibility and precision of attachment management in `surveilr` by introducing a new command-line argument, `--extract-attachments-filter`, allowing users to selectively extract attachments based on a regular expression (regex).

   - **Description:**
   Currently, `surveilr` handles attachments for each resource based on the `--extract-attachments` flag, which accepts the values no, yes, or `uniform-resource`. However, a blanket approach may not be suitable in all scenarios. To address this, we propose the introduction of the `--extract-attachments-filter` argument, which will allow users to specify a regex to match the names of specific attachments they wish to extract. This enhancement will provide more granular control over attachment extraction, catering to various user needs and use cases.

   - **Key Features:**
     - **Selective Extraction:** Enable users to selectively extract attachments based on a regex provided through the `--extract-attachments-filter` argument.
     - **Flexible Management:** Allow more precise control over which attachments are extracted, improving the overall flexibility of the `surveilr` tool.



