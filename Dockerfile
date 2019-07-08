FROM ubuntu:bionic

RUN apt-get update \
  && apt-get -y install --no-install-recommends  python-pip \
  && pip install ansible \
  && rm -rf /var/lib/apt/lists/*

COPY ./ubuntu_geospatial_ansible /home/ubuntu/ubuntu_geospatial_ansible
WORKDIR /home/ubuntu/ubuntu_geospatial_ansible

CMD ["bash"]
