ARG BASE_IMAGE
FROM $BASE_IMAGE

# install ubuntu/debian packages
RUN apt update && apt install -y \

  # basic tools
  curl tar unzip gcc git \

  # for nvim plugins
  make ripgrep xclip \

  # for lazygit.nvim
  lazygit

# install nvim
RUN curl -o /tmp/nvim.tar.gz -LO https://github.com/neovim/neovim/releases/download/v0.11.5/nvim-linux-arm64.tar.gz
RUN tar -C /opt -xzf /tmp/nvim.tar.gz
RUN ln -sf /opt/nvim-linux-arm64/bin/nvim /usr/local/bin/nvim

# create xdg-open bin, through which containers will open staff (e.g. browser links).
# the browser_pipe file should be bound to container and listened from host side (see run.sh)
RUN echo 'echo "$1" >> /tmp/browser_pipe' > /usr/local/bin/xdg-open
RUN chmod +x /usr/local/bin/xdg-open

# configure terminal to use rich color palete
ENV TERM=xterm-256color
ENV COLORTERM=truecolor

# use bash by default, otherwise some linux containers will default to /bin/sh,
# which doesn't support history navigation with up-down arrows, cleaning with Command+L, etc.
ENV SHELL=/bin/bash

