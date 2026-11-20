# Neovim Docker Development Environment

This is my opinionated, simple and flexible approach for wrapping dev environment inside docker container and having VS Code + Dev Containers experience, but using Neovim.

## Common Approach

A common way is to install Neovim inside the container and run the container with Neovim as the shell command. This way, the host terminal acts like a thin client, and Neovim operates directly on the target source code directory. This approach is similar to working with a remote host via SSH, where Neovim is installed directly on the remote machine.

In practice, you typically have Neovim installed on your host environment with a well-established configuration and all plugins installed. You may have multiple dev containers for different projects. You don't want to copy-paste your config each time you start a new dev environment, as it will diverge quickly. You want the same Neovim experience across all projects: the same version of Neovim with the same configuration everywhere.

## Solution Overview

- **Build a new Docker image with Neovim on top of the project's base image.**  
  This image layering keeps the source project's Dockerfile unmodified.

- **Share the Neovim config with the container by binding the host config directory.**

- **Store the Neovim data directory (with all installed plugins) in a named Docker volume.**  
  This persists plugins across container restarts without reinstalling them each time. Use a separate named volume instead of binding to the host filesystem, as the plugins cache contains OS-specific binaries that are not portable between host and container.

## Usage

```sh
neodev/go.sh ~/my-project-dir
```

It will perform two things:

1. **Build the Docker image with Neovim:**

   ```sh
   neodev/build.sh ~/my-project-dir
   ```

   First it will build base docker image using `~/my-project-dir/.devcontainer/Dockerfile`.  
   Then it will build Neovim docker image using `neodev/Dockerfile` on top of base image.

   Rebuild each time changes are made to the project's or Neovim's Dockerfile.

2. **Run the Docker container with the image:**

   ```sh
   neodev/run.sh ~/my-project-dir
   ```

