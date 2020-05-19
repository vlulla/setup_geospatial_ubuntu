#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

## http://redsymbol.net/articles/unofficial-bash-strict-mode/ 
## explains why we need above lines

sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9
echo "deb https://cloud.r-project.org/bin/linux/ubuntu $(lsb_release -cs)-cran40/" | sudo tee -a /etc/apt/sources.list


sudo apt-get -y update && sudo apt-get -y upgrade
sudo apt-get install -y build-essential whois vim curl default-jdk default-jre gdebi postgresql postgresql-contrib libpq-dev imagemagick libmagick++-dev libssl-dev libcurl4-gnutls-dev libgit2-dev protobuf-compiler libprotobuf-dev libjq-dev libv8-dev liblwgeom-dev
sudo apt-get install -y texlive-latex-base texlive-fonts-recommended texlive-fonts-extra texlive-latex-extra texinfo pandoc libudunits2-dev unixodbc-dev libgdal-dev
sudo apt-get install -y r-base r-base-dev r-recommended littler
mkdir -p ${HOME}/.R && touch ${HOME}/.R/Makevars && echo "MAKEFLAGS = -j" >> ${HOME}/.R/Makevars

## ## Uncomment below if you want rstudio server on this instance
## gpg --keyserver keys.gnupg.net --recv-keys 3F32EE77E331692F
## curl -sSO https://download2.rstudio.org/server/bionic/amd64/rstudio-server-1.2.50242-amd64.deb
## if [ ! dpkg-sig verify rstudio-server-1.2.50242-amd64.deb 2>/dev/null ] ; then
##   echo "Could not verify the deb package"
##   exit 1
## fi
## 
## sudo gdebi rstudio-server-1.2.50242-amd64.deb
## echo "www-address=127.0.0.1" | sudo tee -a /etc/rstudio/rserver.conf
## sudo rstudio-server restart
## sudo useradd -m -p $(mkpasswd -m sha-512 ruser) -s /bin/bash ruser
## sudo cp -r ~/.ssh ~ruser/.ssh && sudo chown -R ruser ~ruser/.ssh
## 
## sudo -u postgres createuser --superuser ubuntu
## sudo -u postgres createdb ubuntu
## sudo -u postgres createuser ruser
## sudo -u postgres createdb ruser
## echo "ALTER USER ruser WITH PASSWORD 'ruser'; " | sudo -u postgres psql
## sudo R CMD javareconf
##
## 
## ## To tunnel this you'll have to call it like this:
## ## ssh -i AWSKEY.pem -L 8787:127.0.0.1:8787 ruser@AWSADDRESS

