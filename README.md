## Setting up Ubuntu using shell script

There are two ways to setup a geospatial ubuntu instance (maybe on AWS or local machine).
First, you can just copy the `setup_geospatial_env_ubntu.sh` to the ubuntu machine and
then run `bash setup_geospatial_env_ubntu.sh`.  This shell script installs a few more
things (for instance R, sbt, QGIS, and J) on the machine.  It also allows you to disable
some components that you might not need.


## Setting up Ubuntu using ansible

This method is much more flexible yet robust but I'm not quite sure how to install all
the other software that I need with it yet.  Anyhow you can copy the folder "ubuntu_geospatial_ansible"
to the ubuntu machine and use [ansible](https://www.ansible.com/) to configure your machine.  
The `Readme.md` file in that folder has commands of how to use it!
