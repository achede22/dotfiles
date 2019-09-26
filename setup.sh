#!/bin/bash
# zsh theming

# from Saja , https://github.com/asajaroff/dotfiles/blob/master/setup.sh

#Colors
red=$'\e[1;31m'
grn=$'\e[1;32m'
yel=$'\e[1;33m'
blu=$'\e[1;34m'
mag=$'\e[1;35m'
cyn=$'\e[1;36m'
end=$'\e[0m'

are_you_root(){
    echo $(whoami) | grep root || echo " $red This must be executed as root $end" || exit 1
}

os_selector(){                                                          #Package Manager
    apt-get -v    && echo "$grn Debian Based Distro detected $end" && OS="Debian" && PM="apt-get" && ubuntu_apps 
    yum --version && echo "$grn RedHat Based Distro detected $end" && OS="Centos" && PM="yum"     && centos_apps
}

ubuntu_apps() {
    ##################### UBUNTU "apt" 
    $PM install \
    python3 \
    python3-pip \
    unzip \
    wget \
    curl \
    vim \
    git \
    curl \
    zsh \
    -y # no-interactive mode
}

centos_apps() {
    ##################### CENTOS 7 no tiene Python 3 oficial ( ni pip )
    ## Fedora puede usar dnf en lugar de yum
    yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

    $PM makecache
    $PM update -y
    $PM install yum-utils lvm2  device-mapper-persistent-data zsh vim unzip wget docker-ce git curl python36u python36u-pip -y ## Python 3.6 with pip
    $PM install https://centos7.iuscommunity.org/ius-release.rpm
    $PM install docker-ce docker-ce-cli containerd.io -y
    $PM makecache

    alias python3=$(which python3.6)
    alias pip3=$(which pip3.6)
    pip3.6 install --upgrade pip
    python3.6 -V
    pip3.6 -V
}

###########
echo "$cyn ######################### General configurations $end"
mkdir -p ~/Workspace/Logs ~/Workspace/minikube ~/Workspace/Scripts ~/Workspace/Temp ~/Workspace/Repos

echo "$cyn ######################### Docker  $end"
    systemctl enable docker
    systemctl start docker

echo "$cyn ######################### Installing ZSH"
    sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh) $end"
    echo "Generating symlinks for ~/.zshrc" 
    ln -sf ~/.dotfiles/zshrc ~/.zshrc
    source ~/.zshrc

echo "$cyn #########################Installing Bullet train theme $end"
    wget http://raw.github.com/caiogondim/bullet-train-oh-my-zsh-theme/master/bullet-train.zsh-theme
    mv bullet-train.zsh-theme $ZSH_CUSTOM/themes

# vim setup
    echo "$cyn ######################### Creating necesary directories for vim's swapfiles, backupfiles and undodir $end"
    mkdir -p $HOME/.vim/swapfiles $HOME/.vim/swapfiles $HOME/.vim/backupfiles $HOME/.vim/undodir $HOME/.local/bin
    echo "Generating symlink to vimrc"
    ln -sf ~/.dotfiles/vimrc ~/.vimrc

#######################  Install SRE Tools
    echo "$cyn ######################### Installing AWS cli $end"
	pip3 install awscli --upgrade --user
    rsync -xvr /root/.local/bin/* /usr/local/bin/
    echo $OS | grep Debian && source ~/.profile #ubuntu
    echo $OS | grep Centos && source ~/.bash_profile #centos
    aws --version || echo "$red ERROR $end"
    echo "deberia ser ----> aws-cli/1.16.192 +"

echo "$cyn ######################### aws-iam-authenticator $end"
    curl https://amazon-eks.s3-us-west-2.amazonaws.com/1.11.5/2018-12-06/bin/linux/amd64/aws-iam-authenticator -o aws-iam-authenticator
    mv aws-iam-authenticator /usr/bin/aws-iam-authenticator
    chmod +x /usr/bin/aws-iam-authenticator
    aws-iam-authenticator version  || echo "$red ERROR $end"

echo "$cyn ######################### kubectl $end"
    curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
    chmod +x kubectl
    kubectl version || echo "$red ERROR $end"

# kubens & kubectx
echo "$cyn ######################### kubens and kubectx $end"
    curl https://raw.githubusercontent.com/ahmetb/kubectx/master/kubectx -o kubectx
    curl https://raw.githubusercontent.com/ahmetb/kubectx/master/kubens -o kubens
    chmod +x kube* 
    mv kube* /usr/local/bin/
    kubens -h   || echo "$red ERROR $end"
    kubectx -h  || echo "$red ERROR $end"
 
echo "$cyn ######################### eksctl $end"
    curl --location "https://github.com/weaveworks/eksctl/releases/download/latest_release/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
    sudo mv /tmp/eksctl /usr/local/bin/
    # . <(eksctl completion bash)
    eksctl version || echo "$red ERROR $end"

echo "$cyn ######################### KOPS --> kubectl for clusters $end"
    curl -LO https://github.com/kubernetes/kops/releases/download/$(curl -s https://api.github.com/repos/kubernetes/kops/releases/latest | grep tag_name | cut -d '"' -f 4)/kops-linux-amd64
    chmod +x kops-linux-amd64
    sudo mv kops-linux-amd64 /usr/local/bin/
    kops version  || echo "$red ERROR $end"

echo "$cyn ######################### Terraform $end"
# please check for the latest version
    curl https://releases.hashicorp.com/terraform/0.12.7/terraform_0.12.7_linux_amd64.zip -o terraform.zip
    unzip terraform.zip
    chmod +x terraform
    mv terraform /usr/local/bin/
    terraform version || echo "$red ERROR $end"

echo "$cyn ######################### Mozilla SOPS $end"
    wget https://github.com/mozilla/sops/releases/download/3.2.0/sops-3.2.0.linux
    chmod +x sops-3.2.0.linux
    mv sops /usr/local/bin/
    sops -v  || echo "$red ERROR $end"

echo "$cyn ######################### stern $end"
    wget https://github.com/wercker/stern/releases/download/1.10.0/stern_linux_amd64
    chmod +x stern_linux_amd64
    mv stern_linux_amd64 /usr/local/bin/
    stern -v || echo "$red ERROR $end"

echo "$cyn ######################### helm $end"
    wget https://storage.googleapis.com/kubernetes-helm/helm-v2.9.1-linux-amd64.tar.gz
    tar -xvf helm-v2.9.1-linux-amd64.tar.gz
    chmod +x ./linux-amd64/helm
    mv ./linux-amd64/helm /usr/local/bin/
    helm version || echo "$red ERROR $end"


######################### START HERE

are_you_root
os_selector

cat ~/.aws/credentials
#[regulado-develop]
#aws_access_key_id = XXXXXXXXXXXXXXXXXX
#aws_secret_access_key = XXXXXXXXXXXXXX

#[sandbox-devops]
#aws_access_key_id = XXXXXXXXXXXXXX
#aws_secret_access_key = XXXXXXXXXXXXXX

# export AWS_PROFILE=sandbox-devops


echo " $grn Now mannualy configure AWS and kubectl login $end

        \$ aws configure  # with your AWS access keys
        \$ aws s3 ls      # just to test AWS credentials
        \$ aws eks --region [REGION] update-kubeconfig --name [CLUSTER]
            # Added new context arn:aws:eks:us-east-1:XXXXXXXXXXXXXXXX:cluster/regulada-develop_eks to /root/.kube/config
    "


