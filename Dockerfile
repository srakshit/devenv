FROM centos:centos7
MAINTAINER Subham Rakshit <subham.rakshit@hpe.com>

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
RUN mkdir -p $HOME/.vim/vim-addons && \
    cd $HOME/.vim/vim-addons && \
    git clone --depth=1 https://github.com/MarcWeber/vim-addon-manager && \
    git clone --depth=1 https://github.com/tpope/vim-fugitive fugitive && \
    git clone --depth=1 https://github.com/airblade/vim-gitgutter github-airblade-vim-gitgutter && \
    git clone --depth=1 https://github.com/editorconfig/editorconfig-vim github-editorconfig-editorconfig-vim && \
    git clone --depth=1 https://github.com/geekjuice/vim-spec github-geekjuice-vim-spec && \
    git clone --depth=1 https://github.com/nanotech/jellybeans.vim jellybeans && \
    git clone --depth=1 https://github.com/tomasr/molokai.git && \
    git clone --depth=1 https://github.com/sickill/vim-monokai github-sickill-vim-monokai && \
    git clone --depth=1 https://github.com/Lokaltog/powerline && \
    git clone --depth=1 https://github.com/garbas/vim-snipmate snipmate && \
    git clone --depth=1 https://github.com/majutsushi/tagbar Tagbar && \
    git clone --depth=1 https://github.com/scrooloose/nerdtree The_NERD_tree && \
    git clone --depth=1 https://github.com/tomtom/tlib_vim tlib && \
    git clone --depth=1 https://github.com/MarcWeber/vim-addon-commenting && \
    git clone --depth=1 https://github.com/MarcWeber/vim-addon-mw-utils && \
    git clone --depth=1 https://github.com/Chiel92/vim-autoformat && \
    git clone --depth=1 https://bitbucket.org/vimcommunity/vim-pi && \
    git clone --depth=1 https://github.com/honza/vim-snippets && \
    git clone --depth=1 https://github.com/kristijanhusak/vim-multiple-cursors github-kristijanhusak-vim-multiple-cursors && \
    git clone --depth=1 http://github.com/digitaltoad/vim-jade github-digitaltoad-vim-jade && \
    git clone --depth=1 http://github.com/tpope/vim-cucumber github-tpope-vim-cucumber && \ 
    git clone --depth=1 https://github.com/vim-airline/vim-airline.git
    git clone --depth=1 https://github.com/pangloss/vim-javascript.git
    git clone --depth=1 https://github.com/rstacruz/sparkup.git
    git clone --depth=1 https://github.com/vim-syntastic/syntastic.git
    git clone --depth=1 https://github.com/wincent/command-t.git
    
    mkdir -p /home/docker/.vim/vim-addons/matchit.zip/archive/ && \
    curl --silent -L --max-redirs 40 -o '/home/docker/.vim/vim-addons/matchit.zip/archive/matchit.zip' 'http://www.vim.org/scripts/download_script.php?src_id=8196'

#Install Youcompleteme
RUN cd $HOME/.vim/vim-addons/YouCompleteMe && \
    git submodule update --init --recursive && \
    ./install.sh --clang-completer


#Install powerline
#RUN $HOME/scripts/powerline_setup.sh
