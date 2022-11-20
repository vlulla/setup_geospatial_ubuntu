#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

install_ubuntu_base() {
  local pkgs
  pkgs=( apt-transport-https curl ca-certificates gdal-bin git gnupg graphviz wget
    sqlite3 python3 p7zip-full htop tmux tree zsh zstd unzip liblz4-tool default-jdk jq
    libjq-dev libbz2-dev libicu-dev liblzma-dev ssh less vim libfftw3-dev
    libgdal-dev libgeos-dev libgsl-dev libhdf4-alt-dev libhdf5-dev libproj-dev
    libnetcdf-dev libsqlite3-dev libssh2-1-dev libssl-dev libudunits2-dev libxt-dev
    netcdf-bin protobuf-compiler libxml2-dev
  )
  apt-get update --yes
  apt-get install --yes --auto-remove --no-install-recommends build-essential "${pkgs[@]}"
}

install_R() {
    HOME="${1:-/home/ubuntu}"
    apt-get update --yes -qq && apt-get install --yes -qq --no-install-recommends software-properties-common dirmngr
    wget -qO- https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc | tee -a /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc
    [[ ! -f "/etc/apt/sources.list.d/R.list" ]] && echo "deb [signed-by=/etc/apt/trusted.gpg.d/cran_ubuntu_key.asc] https://cloud.r-project.org/bin/linux/ubuntu $(lsb_release -cs)-cran40/" > /etc/apt/sources.list.d/R.list

    sudo apt-get --yes update && sudo apt-get --yes upgrade
    sudo apt-get install --yes --auto-remove build-essential whois vim curl default-jdk default-jre gdebi postgresql postgresql-contrib libpq-dev imagemagick libmagick++-dev libssl-dev libcurl4-gnutls-dev libgit2-dev protobuf-compiler libprotobuf-dev libjq-dev libv8-dev libcgal-dev libglu1-mesa-dev libx11-dev graphviz liblz4-tool zstd freeglut3-dev  libfontconfig1-dev libnode-dev
    sudo apt-get install --yes --auto-remove texlive-latex-base texlive-fonts-recommended texlive-fonts-extra texlive-latex-extra texinfo pandoc libudunits2-dev unixodbc-dev libgdal-dev
    sudo apt-get install --yes --auto-remove r-base r-base-dev r-recommended littler libfftw3-bin libfftw3-dev

    [ -d "/usr/lib/R/site-library/littler" ] && [[ ! "${PATH}" == */usr/lib/R/site-library/littler* ]] && export PATH="${PATH:+${PATH%%:}:}/usr/lib/R/site-library/littler/bin:/usr/lib/R/site-library/littler/examples"
    mkdir -p "${HOME}/.R" && [ ! -f "${HOME}/.R/Makevars" ] && touch "${HOME}/.R/Makevars"
    if ! grep -q -s -F "MAKEFLAGS += -j" "${HOME}/.R/Makevars"; then
      echo "MAKEFLAGS += -j$(( $( nproc ) - 2))" >> "${HOME}/.R/Makevars"
    fi

    sudo R --quiet --vanilla --no-save --no-restore -e "options(repos='https://cloud.r-project.org/',Ncpus=$(nproc));install.packages(setdiff(c('docopt','BiocManager'), installed.packages()[,'Package']),dependencies=TRUE)"
    sudo "$(which installBioc.r)" graph EBImage
    sudo "$(which install2.r)" --deps TRUE --error --ncpus "$(nproc)" --skipinstalled RSQLite ggplot2 igraph rbenchmark data.table simstudy fst e1071 sf rgdal sp raster lidR RPostgres caret randomForest xgboost vtreat drat stringi
    if ! grep -sF "http://cloudyr.github.io/drat" "${HOME}/.Rprofile"; then
      echo 'drat::addRepo("cloudyr", "http://cloudyr.github.io/drat")' | tee -a "${HOME}/.Rprofile"
    fi
    sudo R --quiet --no-save --no-restore -e "options(repos=c(CRAN='https://cloud.r-project.org/',cloudyr='http://cloudyr.github.io/drat'),Ncpus=$(nproc)); install.packages(setdiff(c('awspack'),installed.packages()[,'Package']),dependencies=TRUE)"
}

## ## Uncomment below if you want rstudio server on this instance
## install_RStudio() {
##     gpg --keyserver keys.gnupg.net --recv-keys 3F32EE77E331692F
##     curl -sSO https://download2.rstudio.org/server/bionic/amd64/rstudio-server-1.2.50242-amd64.deb
##     if [ ! dpkg-sig verify rstudio-server-1.2.50242-amd64.deb 2>/dev/null ] ; then
##       echo "Could not verify the deb package"
##       exit 1
##     fi
##
##     sudo gdebi rstudio-server-1.2.50242-amd64.deb
##     echo "www-address=127.0.0.1" | sudo tee -a /etc/rstudio/rserver.conf
##     sudo rstudio-server restart
##     sudo useradd -m -p $(mkpasswd -m sha-512 ruser) -s /bin/bash ruser
##     sudo cp -r ~/.ssh ~ruser/.ssh && sudo chown -R ruser ~ruser/.ssh
##
##     sudo -u postgres createuser --superuser ubuntu
##     sudo -u postgres createdb ubuntu
##     sudo -u postgres createuser ruser
##     sudo -u postgres createdb ruser
##     echo "ALTER USER ruser WITH PASSWORD 'ruser'; " | sudo -u postgres psql
##     sudo R CMD javareconf
## }
##
##
## ## To tunnel this you'll have to call it like this:
## ## ssh -i AWSKEY.pem -L 8787:127.0.0.1:8787 ruser@AWSADDRESS

install_mambaforge() {
    local pybasepkgs=( dask ipython hypothesis xarray zarr pyarrow matplotlib scikit-learn distributed pytest pytest-xdist s3fs fsspec )
    local pygeopkgs=( geopandas fiona descartes ipython s3fs fsspec )
    local installdir="/home/ubuntu"
    local url="https://github.com/conda-forge/miniforge/releases/latest/download/Mambaforge-Linux-x86_64.sh"

    mkdir -p "${installdir}/Downloads"
    pushd "${installdir}/Downloads"

    [[ ! -f "${url##*/}" ]] && curl -SLO "${url}"
    bash "./${url##*/}" -b -u -p "${installdir}/mambaforge"

    source ${installdir}/mambaforge/bin/activate
    mamba config --add channels conda-forge
    mamba config --set channel_priority strict
    mamba config --set auto_update_conda False
    mamba config --set show_channel_urls True
    mamba install --yes --name base "${pybasepkgs[@]}"
    mamba create --yes --name geo "${pygeopkgs[@]}"
    mamba update --yes --name base --update-all
    mamba update --yes --name geo --update-all
    popd
}

my_config() {
  local user
  user="${1:-ubuntu}"
  userdir="/home/${user}"
  mkdir -p "${userdir}/code"
  pushd "${userdir}/code"
  git clone https://github.com/vlulla/config
  git clone https://github.com/vlulla/vim_templates
  curl -o awscliv2.zip -sL "https://awscli.amazonaws.com/awscli-exe-linux-$(uname -m).zip" && unzip awscliv2.zip && ./aws/install
  mkdir -p "${userdir}/.aws"
  cat > "${userdir}/.aws/config" <<'EOF'
[default]
region=us-east-1
output=json
EOF
  chmod -R og-rwx "${userdir}/.aws"
  popd

  cat <<'EOF' > "${userdir}/.zshrc"
[[ -f "${HOME}/code/config/zshrc" ]] && source "${HOME}/code/config/zshrc"
EOF

  cat <<EOF > "${userdir}/.vimrc"
source "${userdir}/code/config/vimrc"
EOF
  ln -s "${userdir}/code/config/tmux.conf" "${userdir}/.tmux.conf"
  sed -i'' -e '/^ubuntu:/s-/bin/bash-/usr/bin/zsh-g' /etc/passwd
}

install_osquery() {
  local key
  key=1484120AC4E9F8A1A577AEEE97A80C63C9D8B80B
  apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys ${key}
  echo "deb [arch=amd64] https://pkg.osquery.io/deb deb main" > /etc/apt/sources.list.d/osquery.list
  apt-get update
  apt-get install osquery
}

fix_permissions() {
  user="${1:-ubuntu}"
  chown -R "${user}:${user}" "/home/${user}"
}

install_ubuntu_base
## install_R
## install_RStudio
install_mambaforge
install_osquery
my_config
fix_permissions
