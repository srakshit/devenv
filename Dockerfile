FROM centos:centos7

ENV TERM=linux

#Install general tools
RUN yum -y -q install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm && \
    yum -y -q update && \
    yum -y -q install git wget jq unzip which wemux tmux telnet sudo httpie redis curl postgresql

#Install vim8
RUN curl -L https://copr.fedorainfracloud.org/coprs/mcepl/vim8/repo/epel-7/mcepl-vim8-epel-7.repo -o /etc/yum.repos.d/mcepl-vim8-epel-7.repo --silent && \
    yum -y -q install vim*

#Add docker user and add it to sudoers file
RUN groupadd docker && \
    useradd -g docker docker && \
    echo 'docker ALL=(ALL:ALL) NOPASSWD:ALL' >> /etc/sudoers

USER docker

ENV HOME=/home/docker
COPY config $HOME/
COPY scripts $HOME/scripts/

RUN sudo chown -R docker:docker $HOME

#Install nvm, nodejs and npm
ENV NVM_DIR=/usr/local/lib/nvm
ARG NVM_VERSION=0.33.8
RUN sudo mkdir -p $NVM_DIR && \
    cd /tmp && \
    sudo chown -R docker:docker $NVM_DIR && \
    curl -o- https://raw.githubusercontent.com/creationix/nvm/v$NVM_VERSION/install.sh --silent | bash && \
    source $NVM_DIR/nvm.sh && \
    echo "[ -s \"$NVM_DIR/nvm.sh\" ] && \. \"$NVM_DIR/nvm.sh\"" >> $HOME/.profile && \
    echo "[ -s \"$NVM_DIR/bash_completion\" ] && \. \"$NVM_DIR/bash_completion\"" >> $HOME/.profile && \
    source $HOME/.profile

#Install nodejs
ARG NODEJS_VERSION=8.10.0
RUN /bin/bash -l -c "nvm install $NODEJS_VERSION && nvm use $NODEJS_VERSION && nvm cache clear"

#Install npm and some essential packages
ARG NPM_VERSION=5.7.1
RUN /bin/bash -l -c "npm install -g npm@$NPM_VERSION vimdebug yarn grunt-cli npm-check-updates"

#Install Vim plugins
RUN git clone https://github.com/VundleVim/Vundle.vim.git $HOME/.vim/bundle/Vundle.vim
    #vim +PluginInstall +qall

#Install powerline
#RUN $HOME/scripts/powerline_setup.sh
