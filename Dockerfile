FROM centos:centos7

#Install general tools
RUN yum -y -q install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm && \
    yum -y -q update && \
    yum -y -q install git wget jq unzip which wemux tmux telnet sudo httpie redis curl

#Install vim8
RUN curl -L https://copr.fedorainfracloud.org/coprs/mcepl/vim8/repo/epel-7/mcepl-vim8-epel-7.repo -o /etc/yum.repos.d/mcepl-vim8-epel-7.repo --silent && \
    yum -y -q install vim*

#Install nvm
ENV NVM_DIR=/usr/local/lib/nvm
ARG NVM_VERSION
RUN mkdir -p $NVM_DIR && \
    cd /tmp && \
    curl https://raw.githubusercontent.com/creationix/nvm/v$NVM_VERSION/install.sh --output install.sh --silent && \
    chmod +x install.sh && \
    ./install.sh && \
    rm -f install.sh && \
    echo "[ -s \"$NVM_DIR/nvm.sh\" ] && \. \"$NVM_DIR/nvm.sh\"" >> /etc/bashrc && \
    echo "[ -s \"$NVM_DIR/bash_completion\" ] && \. \"$NVM_DIR/bash_completion\"" >> /etc/bashrc

#Install nodejs
ARG NODEJS_VERSION
RUN /bin/bash -l -c "nvm install $NODEJS_VERSION && nvm use $NODEJS_VERSION && nvm cache clear"

#Install npm
ARG NPM_VERSION
RUN /bin/bash -l -c "npm install -g npm@$NPM_VERSION"

ENV HOME=/home/docker
COPY config $HOME/

#Install Vim plugins
RUN git clone https://github.com/VundleVim/Vundle.vim.git $HOME/.vim/bundle/Vundle.vim && \
    vim +PluginInstall +qall