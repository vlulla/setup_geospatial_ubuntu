Run the following in your ubuntu environment!

    sudo apt-get install -y python-pip
    pip install ansible
    ansible-playbook setup.yml -i local.inventory --ask-sudo-pass


Got the idea from using ansible for setting up the ubuntu environment from
[https://github.com/MichaelAquilina/ubuntu-ansible](https://github.com/MichaelAquilina/ubuntu-ansible)