#!/bin/env bash
set -euo pipefail
IFS=$'\n\t'

sudo apt-get --yes && sudo apt-get install --yes --auto-remove --no-install-recommends \
  build-essential apt-transport-https curl ca-certificates gdal-bin git gnupg graphviz wget keepassxc \
  sqlite3 python3 p7zip-full htop postgresql libpq-dev nmap emacs tmux zsh zstd liblz4-tool \
  bwidget default-jdk fonts-roboto ghostscript jq libjq-dev libbz2-dev libicu-dev liblzma-dev \
  libhunspell-dev libmagick++-dev librdf0-dev libnode-dev qpdf texinfo ssh less vim lbzip2 \
  libfftw3-dev libgdal-dev libgeos-dev libgsl-dev libgl1-mesa-dev libglu1-mesa-dev libhdf4-alt-dev libhdf5-dev \
  libproj-dev libnetcdf-dev libsqlite3-dev libssh2-1-dev libssl-dev libudunits2-dev libxt-dev netcdf-bin \
  protobuf-compiler texlive texlive-latex-extra texlive-fonts-recommended texlive-humanities tk-dev unixodbc-dev \
  libxml2-dev


## R
install_R() {
    wget -qO- https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc | sudo tee -a /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc
    [[ ! -f "/etc/apt/sources.list.d/R.list" ]] && echo "deb [signed-by=/etc/apt/trusted.gpg.d/cran_ubuntu_key.asc] https://cloud.r-project.org/bin/linux/ubuntu $(lsb_release -cs)-cran40/" | sudo tee /etc/apt/sources.list.d/R.list > /dev/null
    sudo apt-get -y update && sudo apt-get -y upgrade
    sudo apt-get install -y libopenblas-base r-base r-base-dev r-cran-littler python3-dev

    mkdir -p "${HOME}"/tmp
    pushd "${HOME}"/tmp || return

    local logfile
    local dependencylog
    logfile=R_PKG_INSTALL_$(date +"%Y%m%d").log
    dependencylog=R_PKG_DEPENDENCY_$(date +"%Y%m%d").log

    [ ! -f "${logfile}" ] && touch "${logfile}"
    ## Check <<R directory>>/install_packages_i_use.R to see what packages should be listed here...
    local PKGS_TO_INSTALL=( Matrix RSQLite Rcpp SOAR biganalytics bigmemory bigtabulate caret data.table digest doMC dplyr e1071 ff foreach gbm ggmap ggplot2 glmnet leaflet lpSolve mapview nnet lidR ncdf4 jsonlite geonames igraph rnaturalearth RNetCDF classInt parallel randomForest randtoolbox raster rbenchmark rgdal rgl simstudy sf sp spdep sqldf stringi tau tidyverse tm tmap xgboost xts zoo )
    for pkg in "${PKGS_TO_INSTALL[@]}"; do
        sudo R --vanilla --no-save --no-restore -e "install.packages(c('${pkg}'),repos='https://cloud.r-project.org', dependencies=T)" >> "${logfile}" 2>"${dependencylog}"
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
    echo "deb https://repo.scala-sbt.org/scalasbt/debian all main" | sudo tee /etc/apt/sources.list.d/sbt.list
    echo "deb https://repo.scala-sbt.org/scalasbt/debian /" | sudo tee /etc/apt/sources.list.d/sbt_old.list
    curl -sL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x2EE0EA64E40A89B84B2DF73499E82A75642AC823" | sudo apt-key add
    sudo apt-get -y update && sudo apt-get -y install sbt
}
## docker
install_docker() {
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get --yes update && sudo apt-get install --yes docker-ce docker-ce-cli containerd.io docker-compose-plugin
}

## Lookup R packages from code/R/packages_i_use.R or some such file to see
## how to install requisite R packages.

## Mambaforge
install_mambaforge() {
  local pybasepkgs=( dask ipython hypothesis xarray zarr pyarrow matplotlib scikit-learn distributed pytest pytest-xdist s3fs fsspec )
  local pygeopkgs=( geopandas fiona descartes ipython pyproj s3fs fsspec )
  local installdir="/home/ubuntu"
  local url="https://github.com/conda-forge/miniforge/releases/latest/download/Mambaforge-Linux-x86_64.sh"

  pushd "${installdir}"
  mkdir -p Downloads && cd Downloads
  [[ ! -f "${url##*/}" ]] && curl -SLO "${url}"
  bash "./${url##*/}" -b -u -p ${installdir}/mambaforge

  source ${installdir}/mambaforge/bin/activate && ${installdir}/mambaforge/bin/mamba init zsh
  mamba config --add channels conda-forge
  mamba config --set channel_priority strict
  mamba config --set auto_update_conda False
  mamba config --set show_channel_urls True
  mamba install --yes --name base "${pybasepkgs[@]}"
  mamba create --yes --name geo "${pygeopkgs[@]}"
  mamba update --yes --name base --update-all
  mamba update --yes --name geo --update-all

  chown -R ubuntu:ubuntu ${installdir}/mambaforge
  popd
}

## Go
install_go() {
    pushd "${HOME}"
    local VERSION="1.18.3"
    local OS="linux"
    local ARCH="amd64"
    [ -d "/usr/local/go" ] && sudo rm -rf /usr/local/go

    mkdir -p Downloads && cd Downloads && curl -O "https://dl.google.com/go/go${VERSION}.${OS}-${ARCH}.tar.gz" && sudo tar -C /usr/local -xzf "go${VERSION}.${OS}-${ARCH}.tar.gz"

    mkdir -p "${HOME}/code/go"
    export GOPATH="${HOME}/code/go"
    export PATH="${PATH:+${PATH}:}$(go env GOPATH)/bin"
    popd
}

## Julia
install_julia() {
    if [ -z "${1+x}" ]; then
      local installdir="${HOME}"
    else
      if [ -d "$1" ]; then
        local installdir="$1"
      else
        echo "$1 is not a directory"
        echo "Installing to ${HOME} instead"
        local installdir="${HOME}"
      fi
    fi
    pushd "${installdir}"
    local version="1.7.3"
    local juliagz="julia-${version}-linux-x86_64.tar.gz"
    [ ! -f "${juliagz}" ] && curl -L -O "https://julialang-s3.julialang.org/bin/linux/x64/1.6/${juliagz}"
    tar xf "${juliagz}"
    export PATH="$(pwd)/julia-${version}/bin${PATH:+:${PATH}}"
    rm -rf "${juliagz}"
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
  pushd "${tmpdir}"
  git clone https://git.kernel.org/pub/scm/docs/man-pages/man-pages && cd man-pages && sudo make install
  popd
}

install_spark() {
  if [[ -d "/opt/spark" ]]; then
    echo "spark already installed in /opt/spark ??"
    exit 0
  fi
  trap 'rm -rf "${tmpdir}"' EXIT
  tmpdir=$(mktemp -d -t spark.XXXXXXXX)
  pushd "${tmpdir}"
  echo "Running in $(pwd)"
  sudo apt-get update && sudo apt-get install --yes default-jdk scala curl
  ## apt-get update && apt-get install --yes default-jdk scala curl
  curl -sSL -O https://dlcdn.apache.org/spark/spark-3.2.1/spark-3.2.1-bin-hadoop3.2.tgz
  sudo tar -C /opt -xvf spark-3.2.1-bin-hadoop3.2.tgz
  cd /opt && sudo mv spark-3.2.1-bin-hadoop3.2 spark
  cat <<'EOF' >> ~/.profile
export SPARK_HOME=/opt/spark
export PATH="${PATH:+${PATH}:}${SPARK_HOME}/bin:${SPARK_HOME}/sbin"
export PYSPARK_PYTHON="$(which python3)"
EOF
  popd
}

## Uncomment lines you want to install!
# install_R
# install_go
# install_J
# install_QGIS
# install_sbt
# install_docker
# install_mambaforge
# install_go
# install_julia ${HOME}/VROOT
# install_erlang
# install_elixir
# install_manpages
# install_spark
