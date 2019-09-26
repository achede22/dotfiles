#!/bin/bash
# zsh theming

# from Saja , https://github.com/asajaroff/dotfiles/blob/master/setup.sh

are_you_root(){
    echo $(whoami) | grep root || echo "This must be executed as root" || exit 1
}

os_selector(){
    apt-get -v    && echo "Debian Based Distro detected" && PM="apt-get"  #Package MAnager
    yum --version && echo "RedHat Based Distro detected" && PM="yum" 
}


# UBUNTU "apt" or RedHat "yum"
apt install python3 python3-pip unzip wget curl -y

##################### CENTOS 7 no tiene Python 3 oficial ( ni pip )
yum makecache
yum update -y
yum install yum-utils lvm2  device-mapper-persistent-data zsh vim unzip wget git curl python36u python36u-pip -y ## Python 3.6 with pip
yum install https://centos7.iuscommunity.org/ius-release.rpm
yum makecache


alias python3=$(which python3.6)
alias pip3=$(which pip3.6)
pip3.6 install --upgrade pip
python3.6 -V
pip3.6 -V

###########
echo "######################### General configurations"
mkdir -p ~/Workspace/Logs ~/Workspace/minikube ~/Workspace/Scripts ~/Workspace/Temp ~/Workspace/Repos

echo "######################### Docker "
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum install docker-ce docker-ce-cli containerd.io -y
systemctl enable docker
systemctl start docker

echo "######################### Installing ZSH"
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
echo "Generating symlinks for ~/.zshrc" 
ln -sf ~/.dotfiles/zshrc ~/.zshrc
source ~/.zshrc

echo "#########################Installing Bullet train theme"
wget http://raw.github.com/caiogondim/bullet-train-oh-my-zsh-theme/master/bullet-train.zsh-theme
mv bullet-train.zsh-theme $ZSH_CUSTOM/themes

# vim setup
echo "######################### Creating necesary directories for vim's swapfiles, backupfiles and undodir"
mkdir -p $HOME/.vim/swapfiles $HOME/.vim/swapfiles $HOME/.vim/backupfiles $HOME/.vim/undodir $HOME/.local/bin
echo "Generating symlink to vimrc"
ln -sf ~/.dotfiles/vimrc ~/.vimrc

# Install SRE Tools

echo "######################### Installing AWS cli"
# curl -O https://bootstrap.pypa.io/get-pip.py && python3 get-pip.py --user && 
	pip3 install awscli --upgrade --user
rsync -xvr /root/.local/bin/* /usr/bin/

source ~/.profile #ubuntu
source ~/.bash_profile #centos

aws --version
echo "deberia ser ----> aws-cli/1.16.192 +"

echo "######################### aws-iam-authenticator"
curl https://amazon-eks.s3-us-west-2.amazonaws.com/1.11.5/2018-12-06/bin/linux/amd64/aws-iam-authenticator -o aws-iam-authenticator
mv aws-iam-authenticator /usr/bin/aws-iam-authenticator
chmod +x /usr/bin/aws-iam-authenticator

echo "######################### kubectl"
curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
chmod +x kubectl

# kubens & kubectx
echo "######################### kubens and kubectx"
curl https://raw.githubusercontent.com/ahmetb/kubectx/master/kubectx -o kubectx
curl https://raw.githubusercontent.com/ahmetb/kubectx/master/kubens -o kubens
chmod +x kube* 
mv kube* /usr/local/bin/
 
echo "######################### eksctl"
curl --location "https://github.com/weaveworks/eksctl/releases/download/latest_release/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/bin/
# . <(eksctl completion bash)
eksctl version

echo "######################### KOPS --> kubectl for clusters"
curl -LO https://github.com/kubernetes/kops/releases/download/$(curl -s https://api.github.com/repos/kubernetes/kops/releases/latest | grep tag_name | cut -d '"' -f 4)/kops-linux-amd64
chmod +x kops-linux-amd64
sudo mv kops-linux-amd64 /usr/local/bin/

echo "######################### Terraform"
curl https://releases.hashicorp.com/terraform/0.12.7/terraform_0.12.7_linux_amd64.zip -o terraform.zip
unzip terraform.zip
chmod +x terraform
mv terraform /usr/local/bin/

echo "######################### Mozilla SOPS"
wget https://github.com/mozilla/sops/releases/download/3.2.0/sops-3.2.0.linux
chmod +x sops-3.2.0.linux
mv sops /usr/local/bin/

echo "######################### stern"
wget https://github.com/wercker/stern/releases/download/1.10.0/stern_linux_amd64
chmod +x stern_linux_amd64
mv stern_linux_amd64 /usr/local/bin/

echo "######################### helm"
wget https://storage.googleapis.com/kubernetes-helm/helm-v2.9.1-linux-amd64.tar.gz
tar -xvf helm-v2.9.1-linux-amd64.tar.gz
chmod +x ./linux-amd64/helm
mv ./linux-amd64/helm /usr/local/bin/


## aws configure  # AWS access keys
## aws s3 ls      # test AWS configuration

#get region
# get cluster

# aws eks --region us-east-1 update-kubeconfig --name regulada-develop_eks

## Added new context arn:aws:eks:us-east-1:947293917990:cluster/regulada-develop_eks to /root/.kube/config

##############

cat ~/.aws/credentials
#[regulado-develop]
#aws_access_key_id = XXXXXXXXXXXXXXXXXX
#aws_secret_access_key = XXXXXXXXXXXXXX

#[sandbox-devops]
#aws_access_key_id = XXXXXXXXXXXXXX
#aws_secret_access_key = XXXXXXXXXXXXXX

# export AWS_PROFILE=sandbox-devops


############## START

are_you_root
os_selector
