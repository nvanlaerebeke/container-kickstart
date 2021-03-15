#!/bin/bash

function user_setup {
    USER=nvanlaerebeke
    echo "Setting up $USER"
    echo "$USER   ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/$USER ; chmod 0440 /etc/sudoers.d/$USER

    echo "Allow ssh key for $USER"
    cd /home/$USER
    if [ ! -d .ssh ];
    then
        mkdir .ssh/
    fi

    echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDVhd/xxIr4bVCuVTHZO6MwT5lJDtpD8c4u1vj/gRE36jk/k+gW2Ppf3i7QaOvO0yybgXy8dhwtFk+8vGziU17OTQo8zdFkkZrGD/KAxZ2tP+RpE3ZoHl+4Fa8qjTwWsSVP7tLfnLSOzyICWFSWe8udfgsBP92RLtKtARN7yLuIJGtE8AuSlIWBXBVm8uHoBqbNkeU237QcvBMye/IfRnlCTYuTZQ0AMJr5MTKwWOzeTnTbTQJjPuUSarPXui7bzw0M15bNfvuwAhc2q4FOBU5OGBjiqVMIou6olQomQnG8QKCXV60/853GpZtKVvVT6mzg7YbZbMNpPTL6slThjAYp nvanlaerebeke@crazytje.com" > .ssh/authorized_keys
    chmod 600 .ssh/authorized_keys
    chmod 700 .ssh ; chmod 600 .ssh/authorized_keys
    chown -R $USER:users .ssh
}

function ub_install_terminator {
    add-apt-repository ppa:gnome-terminator
    apt-get update
    apt-get install terminator
}

function setup_centos {
    echo "Running on CentOS"
    echo "Adding epel repository"
    yum install -y epel-release

    echo "Updating system to the latest version"
    yum update -y

    #############
    # Setup RDP #
    #############
    command -v Xorg
    if [ $? -eq 0 ]
    then
        echo "Setting up xRDP"

        yum install -y xrdp
        systemctl enable xrdp
        systemctl start xrdp

        echo "Adding RDP port to the firewall"
        firewall-cmd --add-port=3389/tcp --permanent
        firewall-cmd --reload
    else
        echo "No graphical interface installed"
    fi
}

function setup_ub {
    echo "Running on debian based system"
    echo "Enabling firewall and allowing ssh"
    ufw allow ssh
    ufw enable

    #############
    # Setup RDP #
    #############
    command -v Xorg
    if [ $? -eq 0 ]
    then

        echo "ToDo: Setup xRDP"
    else
        echo "No graphical interface installed"
    fi

    ub_install_terminator
    #echo "Installed tools needed to get things done"
    apt-get install -y make python3 python3-pip

    #echo "Adding NFS4 client support"
    apt-get install -y nfs-common
}

function setup_os {
    if [ -f /etc/centos-release ]
    then
        setup_centos
    fi
    if [ -f /etc/debian_version ]
    then
        setup_ub
    fi
}

function setup_docker_centos {
    source /etc/os-release
    #centos 8 needs docker support added manually (container.io issues)
    if [ "$REDHAT_SUPPORT_PRODUCT_VERSION" -eq "7" ]
    then
        echo "Installing Docker...\n";
        yum install -y yum-utils
        yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
        yum install docker-ce docker-ce-cli containerd.io
        systemctl enable docker
        systemctl start docker
    fi
}

function setup_docker_ub {
    echo "Installing docker-ce"
    apt-get update
    apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

    apt-get update
    apt-get install -y docker-ce docker-ce-cli containerd.io

    echo "Installing docker-compose"
    pip3 install docker-compose
}

function setup_docker {
    if [ -f /etc/centos-release ]
    then
        setup_docker_centos
    fi
    if [ -f /etc/debian_version ]
    then
        setup_docker_ub
    fi
}

function setup_rdp {
    if [ -f /etc/centos-release ]
    then
        setup_docker_centos
    fi
    if [ -f /etc/debian_version ]
    then
        setup_docker_ub
    fi
}

user_setup
setup_os 
setup_docker
setup_rdp

###################
# System Settings #
###################

#echo "Upping inotify and max open files for monodevelop \n"
#up some limits so that monodevelop can work without issue (100% CPU problem)
#cat <<EOT >> /etc/security/limits.conf
#* soft nproc 65535
#* hard nproc 65535
#* soft nofile 65535
#* hard nofile 65535
#EOT
#cat <<EOT >> /etc/sysctl.conf
#fs.inotify.max_user_watches=32768
#fs.file-max = 100000
#EOT




