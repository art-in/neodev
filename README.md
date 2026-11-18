# Neovim Docker Development Environment

Build and run a Docker container with a development environment using Neovim as the editor.

## Overview

You already have a Docker image with all necessary software installed. You map the directory containing your project's source code into the container when starting it, creating a development environment for that project.

This is similar to how dev containers work in VS Code.

Now, you want to use Neovim as your editor.

## Common Approach

A common way is to install Neovim inside the container and run the container with Neovim as the shell command. This way, the host terminal acts like a thin client, and Neovim operates directly on the target source code directory. This approach is similar to working with a remote host via SSH, where Neovim is installed directly on the remote machine.

In practice, you typically have Neovim installed on your host environment with a well-established configuration and all plugins installed. You may have multiple dev containers for different projects. You don't want to copy-paste your config each time you start a new dev environment, as it will diverge quickly. You want the same Neovim experience across all projects: the same version of Neovim with the same configuration everywhere.

## Solution Overview

- **Build a new Docker image with Neovim on top of the project's base image.**  
  This image layering keeps the source project's Dockerfile unmodified.

- **Share the Neovim config with the container by binding the host config directory.**

- **Store the Neovim data directory (with all installed plugins) in a named Docker volume.**  
  This persists plugins across container restarts without reinstalling them each time. Use a separate named volume instead of binding to the host filesystem, as the plugins cache contains OS-specific binaries that are not portable between host and container.

## Terminal on macOS

Neovim can be configured to copy text into the system clipboard when yanking. However, this would be the container's clipboard, not the host's.

Ideally, a terminal can copy selected text using the default Command-C shortcut, but this doesn't work in the default macOS Terminal app.

Use iTerm2 instead, as it allows the following:

- **Copy text:**  
  Hold Option and highlight text with the mouse cursor, then press Command+C.  
  (iTerm2 will put the highlighted text into the system clipboard.)

- **Paste text:**  
  Activate Insert mode in Neovim, then press Command+V.  
  (iTerm2 will type the text from the system clipboard.)

- **Open web links in the default host browser:**  
  Hold Command and click the link.

## Usage

1. **Build the Docker image with Neovim:**

   ```sh
   ~/Projects/neodev/build.sh rust-sandbox
   ```

   Rebuild each time changes are made to the project's or Neovim's Dockerfile.

2. **Run the Docker container with the image:**

   ```sh
   ~/Projects/neodev/run.sh rust-sandbox
   ```

   Use this as the main way to start the dev environment for a project.

Or just use combination of build and run:

  ```sh
  ~/Projects/neodev/go.sh rust-sandbox
  ```
