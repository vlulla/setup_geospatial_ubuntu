FROM ubuntu:bionic

## RUN apt-get update && apt-get install -y python-pip && pip install ansible

COPY ./ubuntu_geospatial_ansible /home/ubuntu/ubuntu_geospatial_ansible
WORKDIR /home/ubuntu/ubuntu_geospatial_ansible

CMD ["bash"]
