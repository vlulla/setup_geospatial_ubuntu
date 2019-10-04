#!/usr/bin/env bash
sudo apt-get install -y build-essentials apt-transport-https curl ca-certificates \
  gdal-bin gdal-core git gnupg graphviz wget keepassxc sqlite3 python3 p7zip-full \
  htop postgresql libpq-dev nmap emacs tmux zsh libcurl4-openssl-dev

sudo apt-get install -y --no-install-recommends \
  bwidget \
  default-jdk \
  fonts-roboto \
  ghostscript \
  jq \
  libjq-dev \
  libbz2-dev \
  libicu-dev \
  liblzma-dev \
  libhunspell-dev \
  libmagick++-dev \
  librdf0-dev \
  libv8-dev \
  qpdf \
  texinfo \
  ssh \
  less \
  vim \
  lbzip2 \
  libfftw3-dev \
  libgdal-dev \
  libgeos-dev \
  libgsl0-dev \
  libgl1-mesa-dev \
  libglu1-mesa-dev \
  libhdf4-alt-dev \
  libhdf5-dev \
  liblwgeom-dev \
  libproj-dev \
  libnetcdf-dev \
  libsqlite3-dev \
  libssh2-1-dev \
  libssl-dev \
  libudunits2-dev \
  libv8-dev \
  libxt-dev \
  netcdf-bin \
  protobuf-compiler \
  texlive \
  texlive-latex-extra \
  texlive-fonts-recommended \
  texlive-humanities \
  tk-dev \
  unixodbc-dev \
  libxml2-dev

## R
install_R() {
    echo "# R\ndeb https://ftp.ussg.iu.edu/CRAN/bin/linux/ubuntu bionic-cran35/" | sudo tee -a /etc/apt/sources.list
    sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9
    sudo apt-get -y update && sudo apt-get -y upgrade
    sudo apt-get install -y libopenblas-base r-base r-base-dev r-cran-littler python3-dev
}

## QGIS
install_QGIS() {
   echo "## QGIS\ndeb https://qgis.org/ubuntu bionic main\ndeb-src https://qgis.org/ubuntu bionic main" | sudo tee -a /etc/apt/sources.list
   sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-key CAEB3DC3BDF7FB45
   sudo apt-get -y update && sudo apt-get -y upgrade
   sudo apt-get -y install qgis-server python-qgis
}

## JQt
install_J() {
    sudo apt-get install -y libqt5webkit5 libqt5websockets5 libqt5multimediawidgets5
}

## sbt
install_sbt() {
    echo "## sbt\ndeb https://dl.bintray.com/sbt/debian /" | sudo tee -a /etc/apt/sources.list
    sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 2EE0EA64E40A89B84B2DF73499E82A75642AC823
    sudo apt-get -y update && sudo apt-get -y install sbt
}
## docker
install_docker() {
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    echo "## docker\n" | sudo tee -a /etc/apt/sources.list
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    sudo apt-get update -y && sudo apt-get install -y docker-ce
}

## Lookup R packages from code/R/packages_i_use.R or some such file to see
## how to install requisite R packages.

## Anaconda
install_anaconda() {
    pushd $HOME
    mkdir -p Downloads
    cd Downloads
    wget https://repo.anaconda.com/archive/Anaconda3-2019.03-Linux-x86_64.sh
    bash Anaconda3-2019.03-Linux-x86_64.sh -b
    echo 'export PATH="/home/ubuntu/anaconda3/bin:$PATH"' >> ~/.bashrc
    export PATH="/home/ubuntu/anaconda3/bin:$PATH"
    conda upgrade -y --all
    conda install -c conda-forge geopandas
    popd
}

## Go
install_go() {
    local VERSION=1.13.1
    local OS=linux
    local ARCH=amd64

    pushd $HOME
    mkdir -p Downloads && cd Downloads
    [ -d "/usr/local/go" ] && sudo rm -rf /usr/local/go
    curl -O https://dl.google.com/go/go${VERSION}.${OS}-${ARCH}.tar.gz && sudo tar -C /usr/local -xzf go${VERSION}.${OS}-${ARCH}.tar.gz

    mkdir -p $HOME/code/go/gocode
    export GOPATH=$HOME/code/go/gocode
    export PATH=$PATH:${GOPATH}/bin

    popd
}

## Julia
install_julia() {
    juliagz=julia-1.2.0-linux-x86_64.tar.gz
    mkdir -p $HOME/VROOT
    pushd $HOME/VROOT
    [ -d "julia-1.2.0" ] && exit
    curl -L -O https://julialang-s3.julialang.org/bin/linux/x64/1.2/$juliagz
    tar xf $juliagz && rm -rf $juliagz
    export PATH=$PATH:$HOME/VROOT/julia-1.2.0/bin
    popd
}

## Uncomment whatever you wish to install
# install_R
# install_J
# install_QGIS
# install_sbt
# install_docker
# install_anaconda
# install_go
# install_julia
