#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

## http://redsymbol.net/articles/unofficial-bash-strict-mode/ 
## explains why we need above lines

install_R() {
    sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9
    if ! grep -qF "$(lsb_release -cs)-cran40/" /etc/apt/sources.list.d/R.list; then
        echo "deb https://cloud.r-project.org/bin/linux/ubuntu $(lsb_release -cs)-cran40/" | sudo tee -a /etc/apt/sources.list.d/R.list
    fi


    sudo apt-get --yes update && sudo apt-get --yes upgrade
    sudo apt-get install --yes --auto-remove build-essential whois vim curl default-jdk default-jre gdebi postgresql postgresql-contrib libpq-dev imagemagick libmagick++-dev libssl-dev libcurl4-gnutls-dev libgit2-dev protobuf-compiler libprotobuf-dev libjq-dev libv8-dev libcgal-dev libglu1-mesa-dev libx11-dev graphviz liblz4-tool zstd freeglut3-dev  libfontconfig1-dev libnode-dev
    sudo apt-get install --yes --auto-remove texlive-latex-base texlive-fonts-recommended texlive-fonts-extra texlive-latex-extra texinfo pandoc libudunits2-dev unixodbc-dev libgdal-dev
    sudo apt-get install --yes --auto-remove r-base r-base-dev r-recommended littler libfftw3-bin libfftw3-dev

    [ -d "/usr/lib/R/site-library/littler" ] && [[ ! "${PATH}" == */usr/lib/R/site-library/littler* ]] && export PATH="${PATH:+${PATH%%:}:}/usr/lib/R/site-library/littler/bin:/usr/lib/R/site-library/littler/examples"
    mkdir -p "${HOME}/.R" && [ ! -f "${HOME}/.R/Makevars" ] && touch "${HOME}/.R/Makevars"
    if ! grep -q -s -F "MAKEFLAGS += -j" "${HOME}/.R/Makevars"; then
      echo "MAKEFLAGS += -j" >> "${HOME}/.R/Makevars"
    fi

    sudo R --quiet --vanilla --no-save --no-restore -e "options(repos='https://cloud.r-project.org/',Ncpus=$(nproc));install.packages(setdiff(c('docopt','BiocManager'), installed.packages()[,'Package']),dependencies=TRUE)"
    sudo "$(which installBioc.r)" graph EBImage
    sudo "$(which install2.r)" --deps TRUE --error --ncpus "$(nproc)" --skipinstalled RSQLite ggplot2 igraph rbenchmark data.table simstudy fst e1071 sf rgdal sp raster lidR RPostgres caret randomForest xgboost vtreat drat stringi
    if ! grep -sF "http://cloudyr.github.io/drat" ${HOME}/.Rprofile; then
      echo 'drat::addRepo("cloudyr", "http://cloudyr.github.io/drat")' | tee -a ${HOME}/.Rprofile
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

install_anaconda() {
    local VERSION="2020.11"
    pushd ${HOME}
    mkdir -p Downloads
    cd Downloads
    wget https://repo.anaconda.com/archive/Anaconda3-${VERSION}-Linux-x86_64.sh
    bash Anaconda3-${VERSION}-Linux-x86_64.sh -b
    ## echo 'export PATH="${HOME}/anaconda3/bin${PATH:+:${PATH}}"' >> ~/.zshrc
    ## export PATH="${HOME}/anaconda3/bin${PATH:+:${PATH}}"
    source ${HOME}/anaconda3/bin/activate && ${HOME}/anaconda3/bin/conda init zsh
    conda upgrade -y --all
    conda install -y -c conda-forge geopandas dask fiona descartes stumpy hypothesis
    popd
}

install_R
## install_RStudio
## install_anaconda
