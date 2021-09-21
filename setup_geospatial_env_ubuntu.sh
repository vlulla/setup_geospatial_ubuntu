#!/bin/env bash
sudo apt-get install --yes --auto-remove build-essential apt-transport-https curl ca-certificates \
  gdal-bin gdal-core git gnupg graphviz wget keepassxc sqlite3 python3 p7zip-full \
  htop postgresql libpq-dev nmap emacs tmux zsh libcurl4-openssl-dev zstd liblz4-tool

sudo apt-get install --yes --auto-remove --no-install-recommends \
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
    echo "# R\ndeb https://ftp.ussg.iu.edu/CRAN/bin/linux/ubuntu focal-cran40/" | sudo tee -a /etc/apt/sources.list
    sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9
    sudo apt-get -y update && sudo apt-get -y upgrade
    sudo apt-get install -y libopenblas-base r-base r-base-dev r-cran-littler python3-dev

    mkdir -p ${HOME}/tmp
    pushd ${HOME}/tmp
    local logfile=R_PKG_INSTALL_$(date +"%Y%m%d").log
    local dependencylog=R_PKG_DEPENDENCY_$(date +"%Y%m%d").log
    [ ! -f ${logfile} ] && touch ${logfile}
    ## Check <<R directory>>/install_packages_i_use.R to see what packages should be listed here...
    local PKGS_TO_INSTALL="Matrix RSQLite Rcpp SOAR biganalytics bigmemory bigtabulate caret data.table digest doMC dplyr e1071 ff foreach gbm ggmap ggplot2 glmnet leaflet lpSolve mapview nnet lidR ncdf4 jsonlite geonames igraph rnaturalearth RNetCDF classInt parallel randomForest randtoolbox raster rbenchmark rgdal rgl simstudy sf sp spdep sqldf stringi tau tidyverse tm tmap xgboost xts zoo"
    for pkg in ${PKGS_TO_INSTALL}; do
        sudo R --vanilla --no-save --no-restore -e "install.packages(c('${pkg}'),repos='https://cloud.r-project.org', dependencies=T)" >> ${logfile} 2>${dependencylog}
    done
    popd
}

## QGIS
install_QGIS() {
   wget -qO - https://qgis.org/downloads/qgis-2021.gpg.key | sudo gpg --no-default-keyring --keyring gnupg-ring:/etc/apt/trusted.gpg.d/qgis-archive.gpg --import
   sudo chmod a+r /etc/apt/trusted.gpg.d/qgis-archive.gpg
   sudo add-apt-repository "deb https://qgis.org/ubuntu $(lsb_release -c -s) main"
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
    pushd ${HOME}
    mkdir -p Downloads
    cd Downloads
    wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda-installer.sh
    bash miniconda-installer.sh -b -p ${HOME}/miniconda3
    ## echo 'export PATH="${HOME}/miniconda3/bin${PATH:+:${PATH}}"' >> ~/.zshrc
    ## export PATH="${HOME}/miniconda3/bin${PATH:+:${PATH}}"
    source ${HOME}/miniconda3/bin/activate && ${HOME}/miniconda3/bin/conda init zsh
    conda config --add channels 'r'
    conda config --add channels conda-forge
    conda config --set channel_priority strict
    conda config --set auto_update_conda False
    conda config --set auto_activate_base False
    conda config --set show_channel_urls True
    conda update -y conda
    conda create -y -n geo
    conda install -y -n geo geopandas dask fiona descartes stumpy hypothesis ipython
    popd
}

## Go
install_go() {
    pushd ${HOME}
    local VERSION="1.17.1"
    local OS="linux"
    local ARCH="amd64"
    [ -d "/usr/local/go" ] && sudo rm -rf /usr/local/go

    mkdir -p Downloads
    cd Downloads && curl -O https://dl.google.com/go/go${VERSION}.${OS}-${ARCH}.tar.gz && sudo tar -C /usr/local -xzf go${VERSION}.${OS}-${ARCH}.tar.gz

    mkdir -p ${HOME}/code/go
    export GOPATH=${HOME}/code/go
    export PATH=${PATH:+${PATH}:}$(go env GOPATH)/bin
    popd
}

## Julia
install_julia() {
    pushd ${HOME}
    juliagz=julia-1.6.2-linux-x86_64.tar.gz
    [ ! -f ${juliagz} ] && curl -L -O https://julialang-s3.julialang.org/bin/linux/x64/1.6/${juliagz}
    tar xf ${juliagz}
    export PATH="$(pwd)/julia-1.6.2/bin${PATH:+:${PATH}}"
    rm -rf ${juliagz}
    popd
}

install_erlang() {
    sudo apt-get install -y erlang
    ## If you need to compile erlang from source then you'll need the following
    ## sudo apt-get install -y build-essential libncurses5-dev libncursesw5-dev xsltproc fop libgl1-mesa-dev libxml2-utils libssl-dev default-jdk unixodbc-dev
}

install_elixir() {
    sudo apt-get install -y elixir
}

install_manpages() {
  sudo apt-get install --yes --autoremove manpages manpages-dev manpages-posix manpages-posix-dev
  trap 'rm -rf "${tmpdir}"' EXIT
  tmpdir=$(mktemp -d -t manpages.XXXXXXXX)
  pushd ${tmpdir}
  git clone https://git.kernel.org/pub/scm/docs/man-pages/man-pages
  cd man-pages
  sudo make install
  popd
}

## Uncomment lines you want to install!
# install_R
# install_go
# install_J
# install_QGIS
# install_sbt
# install_docker
# install_anaconda
# install_go
# install_julia
# install_erlang
# install_elixir
install_manpages
