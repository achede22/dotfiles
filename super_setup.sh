#!/bin/bash

#dotfiles/super_setup.sh
#@achede22

#Colors
red=$'\e[1;31m'
grn=$'\e[1;32m'
yel=$'\e[1;33m'
blu=$'\e[1;34m'
mag=$'\e[1;35m'
cyn=$'\e[1;36m'
end=$'\e[0m'

are_you_root(){
    if [[ $EUID -ne 0 ]]; then
        echo "This script must be run as root" 
        exit 1
    fi
}

os_selector(){     #Package Manager

    if [[ -f /etc/debian_version   ]] ; then    ##### Debian Based
        echo "$grn Debian Based Distro detected $end"
        OS="Debian"
        PM="apt-get"
        ubuntu_apps
    elif [[ -f /etc/redhat_release ]]; then     ##### RedHat Based
        echo "$grn RedHat Based Distro detected $end"
        OS="Centos"
        PM="yum"    
        centos_apps
    fi
}


ubuntu_apps() {
    ##################### UBUNTU "apt" 
    echo "$cyn ######################### Refresh OS repo $end"
    $PM update -y 

    echo "$cyn ######################### Install Updates $end"
    $PM upgrade -y
    
    echo "$cyn ######################### Install Base Apps $end"
    $PM install \
    snap \
    python3 \
    python3-pip \
    unzip \
    wget \
    vim \
    git \
    curl \
    apt-transport-https ca-certificates curl -y \
    gnupg software-properties-common \
    -y # no-interactive mode
}

centos_apps() {
    ##################### CENTOS 7 no tiene Python 3 oficial ( ni pip )
    ## Fedora puede usar dnf en lugar de yum
    yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

    $PM makecache
    $PM update -y
    $PM install yum-utils lvm2  snap device-mapper-persistent-data vim unzip wget docker-ce git curl python36u python36u-pip -y ## Python 3.6 with pip
    $PM install https://centos7.iuscommunity.org/ius-release.rpm
  #  $PM install docker-ce docker-ce-cli containerd.io -y    # Docker
    $PM makecache

    alias python3=$(which python3.6)
    alias pip3=$(which pip3.6)
    pip3.6 install --upgrade pip
    python3.6 -V
    pip3.6 -V
}

# Oh my zsh! 
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"


f_INSTALL() {
    

###########
echo "$cyn ######################### General configurations $end"
mkdir -p ~/Workspace/Logs ~/Workspace/minikube ~/Workspace/Scripts ~/Workspace/Temp ~/Workspace/Repos

#  echo "$cyn ######################### Docker  $end"
#     systemctl enable docker
#     systemctl start docker

echo "$cyn ######################### Installing ZSH"
    $PM install zsh -y

    # set ZSH as the default login shel
    usermod -s /usr/bin/zsh $(whoami)
    zsh --version
    source ~/.zshrc

echo "$cyn ######################### Installing ZSH Bullet train theme $end"
    wget http://raw.github.com/caiogondim/bullet-train-oh-my-zsh-theme/master/bullet-train.zsh-theme
    mv bullet-train.zsh-theme $ZSH_CUSTOM/themes

# vim setup
    echo "$cyn ######################### Creating necesary directories for vim's swapfiles, backupfiles and undodir $end"
    mkdir -p $HOME/.vim/swapfiles $HOME/.vim/swapfiles $HOME/.vim/backupfiles $HOME/.vim/undodir $HOME/.local/bin
    echo "Generating symlink to vimrc"
    ln -sf ~/.dotfiles/vimrc ~/.vimrc

# #######################  Install AWS SRE Tools
# 
#     echo "$cyn ######################### Installing AWS cli $end"
# 	pip3 install awscli --upgrade --user
#     rsync -xvr /root/.local/bin/* /usr/local/bin/
#     echo $OS | grep Debian && source ~/.profile #ubuntu
#     echo $OS | grep Centos && source ~/.bash_profile #centos
#     aws --version || echo "$red ERROR $end"
#     echo "deberia ser ----> aws-cli/1.16.192 +"
# 
# echo "$cyn ######################### aws-iam-authenticator $end"
#     curl https://amazon-eks.s3-us-west-2.amazonaws.com/1.11.5/2018-12-06/bin/linux/amd64/aws-iam-authenticator -o aws-iam-authenticator
#     mv aws-iam-authenticator /usr/bin/aws-iam-authenticator
#     chmod +x /usr/bin/aws-iam-authenticator
#     aws-iam-authenticator version  || echo "$red ERROR $end"
# 
# 
# # kubens & kubectx
# echo "$cyn ######################### kubens and kubectx $end"
#     curl https://raw.githubusercontent.com/ahmetb/kubectx/master/kubectx -o kubectx
#     curl https://raw.githubusercontent.com/ahmetb/kubectx/master/kubens -o kubens
#     chmod +x kube* 
#     mv kube* /usr/local/bin/
#     kubens -h   || echo "$red ERROR $end"
#     kubectx -h  || echo "$red ERROR $end"
#  
# echo "$cyn ######################### eksctl $end"
#     curl --location "https://github.com/weaveworks/eksctl/releases/download/latest_release/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
#     sudo mv /tmp/eksctl /usr/local/bin/
#     # . <(eksctl completion bash)
#     eksctl version || echo "$red ERROR $end"
# 
# echo "$cyn ######################### KOPS --> kubectl for clusters $end"
#     curl -LO https://github.com/kubernetes/kops/releases/download/$(curl -s https://api.github.com/repos/kubernetes/kops/releases/latest | grep tag_name | cut -d '"' -f 4)/kops-linux-amd64
#     chmod +x kops-linux-amd64
#     sudo mv kops-linux-amd64 /usr/local/bin/
#     kops version  || echo "$red ERROR $end"
# 

# #######################  Install Google Cloud SRE Tools

echo "$cyn ######################### GCP gcloud $end"
    # Add the Cloud SDK distribution URI as a package source
    echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
    
    # Make sure you have apt-transport-https installed:
    $PM install apt-transport-https ca-certificates gnupg -y
    
    #Import key 
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -

    # Update and Install SDK 
    $PM update && sudo apt-get install google-cloud-sdk -y



echo "$cyn ######################### kubectl $end"
    $PM update
    $PM install -y apt-transport-https ca-certificates curl -y

    # Download the Google Cloud public signing key:
    sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg

    # Add the Kubernetes apt repository:
    echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

    $PM update -y
    $PM install -y kubectl


# echo "$cyn ######################### Mozilla SOPS $end"
#     wget https://github.com/mozilla/sops/releases/download/3.2.0/sops-3.2.0.linux
#     chmod +x sops-3.2.0.linux
#     mv sops /usr/local/bin/
#     sops -v  || echo "$red ERROR $end"
# 
# echo "$cyn ######################### stern $end"
#     wget https://github.com/wercker/stern/releases/download/1.10.0/stern_linux_amd64
#     chmod +x stern_linux_amd64
#     mv stern_linux_amd64 /usr/local/bin/
#     stern -v || echo "$red ERROR $end"


echo "$cyn ######################### Terraform $end"
# please check for the latest version
    # Install Dependencies
    $PM update && sudo apt-get install -y gnupg software-properties-common curl

    # Add the HashiCorp GPG key.
    curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -

    # Add the official HashiCorp Linux repository
    sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"

    # Update to add the repository, and install the Terraform CLI
    $PM update && sudo apt-get install terraform
  
    terraform version || echo "$red ERROR $end"


echo "$cyn ######################### helm $end"
    # SNAP verison 
    # https://github.com/snapcrafters/helm
    # sudo snap install helm --classic
    curl https://baltocdn.com/helm/signing.asc | sudo apt-key add -
    sudo apt-get install apt-transport-https --yes
    echo "deb https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
    sudo apt-get update
    sudo apt-get install helm

 
    helm version || echo "$red ERROR $end"
   
echo "$cyn ######################### brew $end"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    
    echo "$cyn ######################### kubectx  $end" 
    brew install kubectx
    echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> /home/hernan.deleon/.profile
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

}


# f_final(){
    
#   cat ~/.aws/credentials



# echo " $grn Now mannualy configure AWS and kubectl login $end
#         \$ aws configure  # with your AWS access keys
#         \$ aws s3 ls      # just to test AWS credentials
#         \$ aws eks --region [REGION] update-kubeconfig --name [CLUSTER]
# 	
# 	    \$ aws eks --region us-east-1 update-kubeconfig --name regulada-develop_eks
#             # Added new context arn:aws:eks:us-east-1:XXXXXXXXXXXXXXXX:cluster/regulada-develop_eks to /root/.kube/config
#     "

# }

######################### START HERE

are_you_root
os_selector

f_INSTALL


