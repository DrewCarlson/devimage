FROM debian:10

RUN apt-get update \
    && apt-get install -y \
    curl \
    dumb-init \
    htop \
    locales \
    man \
    gnupg \
    git \
    rsync \
    unzip \
    zip \
    ssh \
    sudo \
    openssh-server

RUN mkdir /var/run/sshd
RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

# https://wiki.debian.org/Locale#Manually
RUN sed -i "s/# en_US.UTF-8/en_US.UTF-8/" /etc/locale.gen \
  && locale-gen
ENV LANG=en_US.UTF-8

RUN chsh -s /bin/bash
ENV SHELL=/bin/bash

RUN adduser --gecos '' --disabled-password coder && \
  echo "coder ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/nopasswd

RUN ARCH="$(dpkg --print-architecture)" && \
    curl -fsSL "https://github.com/boxboat/fixuid/releases/download/v0.4.1/fixuid-0.4.1-linux-$ARCH.tar.gz" | tar -C /usr/local/bin -xzf - && \
    chown root:root /usr/local/bin/fixuid && \
    chmod 4755 /usr/local/bin/fixuid && \
    mkdir -p /etc/fixuid && \
    printf "user: coder\ngroup: coder\n" > /etc/fixuid/config.yml

# Zsh
RUN apt-get install zsh -y \
      && sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

# nodejs
RUN curl -sL https://deb.nodesource.com/setup_14.x | bash - \
      && apt-get install -y nodejs

# java
RUN apt-get install -y openjdk-11-jdk

# Golang
RUN apt-get install -y golang-go

# Rust
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y

# Krypton
RUN curl https://krypt.co/kr | sh

# Sdkman
RUN apt-get curl -s https://get.sdkman.io | bash

# Cleanup
RUN apt-get autoremove && apt-get clean

USER coder
EXPOSE 22
WORKDIR /home/coder
ENTRYPOINT ["dumb-init", "fixuid", "-q", "/usr/sbin/sshd", "-D"]
