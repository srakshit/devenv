FROM centos:centos7

#Install general tools
RUN yum -y -q install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm && \
    yum -y -q update && \
    yum -y -q install git wget jq unzip which wemux tmux telnet sudo httpie redis curl

#Install vim8
RUN curl -L https://copr.fedorainfracloud.org/coprs/mcepl/vim8/repo/epel-7/mcepl-vim8-epel-7.repo -o /etc/yum.repos.d/mcepl-vim8-epel-7.repo --silent && \
    yum -y -q install vim*

ENV HOME=/home/docker
COPY config $HOME/

#Install Vim plugins
RUN git clone https://github.com/VundleVim/Vundle.vim.git $HOME/.vim/bundle/Vundle.vim && \
    vim +PluginInstall +qall

#Install nvm
ENV NVM_DIR=/usr/local/lib/nvm
ARG NVM_VERSION=0.33.8
RUN mkdir -p $NVM_DIR && \
    cd /tmp && \
    curl -o- https://raw.githubusercontent.com/creationix/nvm/v$NVM_VERSION/install.sh --silent | bash
#    chmod +x install.sh && \
#    ./install.sh && \
#    rm -f install.sh

#Install nodejs
ARG NODEJS_VERSION=8.10.0
RUN /bin/bash -l -c "nvm install $NODEJS_VERSION && nvm use $NODEJS_VERSION && nvm cache clear"

#Install npm
ARG NPM_VERSION=5.7.1
RUN /bin/bash -l -c "npm install -g npm@$NPM_VERSION"

#Install node-vim-debugger
RUN /bin/bash -l -c "npm install -g vimdebug"
