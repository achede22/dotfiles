default: conky yq docker

conky:
	sudo apt install conky-all -y
	echo ln -s ${HOME}/.dotfiles/config/conky.conf ${HOME}/.config/conky/conky.conf

yq:
	sudo add-apt-repository ppa:rmescandon/yq -y
	sudo apt update
	sudo apt install yq -y

docker:
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
	sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(shell lsb_release -cs) stable"
	sudo apt-get update
	sudo apt-get -y -o Dpkg::Options::="--force-confnew" install docker-ce
	mkdir -p ~/.docker/cli-plugins
	curl -L https://github.com/docker/buildx/releases/download/v0.3.1/buildx-v0.3.1.linux-amd64 -o ~/.docker/cli-plugins/docker-buildx
	chmod 755 ~/.docker/cli-plugins/docker-buildx
	docker buildx create --name builder --use 
