FROM debian:10

RUN apt-get update

RUN apt-get install -y curl gnupg

RUN apt-get update
RUN apt-get upgrade -y

# Misc
RUN apt-get -y git rsync unzip zip

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
RUN apt-get install unzip zip && curl -s https://get.sdkman.io | bash

# Cleanup
RUN apt-get autoremove && apt-get clean
