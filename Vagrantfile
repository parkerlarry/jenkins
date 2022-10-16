$docker_install = <<-EOF

curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker vagrant
rm -f get-docker.sh

EOF

$jenkins_nginx_install = <<-EOF

chown $(id -u vagrant):$(id -g vagrant) /home/vagrant/jenkins_home
chown $(id -u vagrant):$(id -g vagrant) /home/vagrant/jenkins/certs/privkey.pem
chown $(id -u vagrant):$(id -g vagrant) /home/vagrant/jenkins/certs/fullchain.pem

docker network create cicd-network

docker build -f /home/vagrant/jenkins/jenkins.dockerfile /home/vagrant/jenkins/ \
--build-arg UID=$(id -u vagrant) \
--build-arg GID=$(id -g vagrant) \
--tag jenkins-image

docker run --detach --restart on-failure \
-u $(id -u vagrant):$(id -g vagrant) \
--mount type=bind,src=/home/vagrant/jenkins_home,dst=/var/jenkins_home \
--name jenkins \
--network cicd-network \
jenkins-image

docker container run \
--mount type=bind,src=/home/vagrant/jenkins/conf.d/default.conf,target=/etc/nginx/conf.d/default.conf \
--mount type=bind,src=/home/vagrant/jenkins/certs/privkey.pem,dst=/usr/share/nginx/certs/privkey.pem,readonly \
--mount type=bind,src=/home/vagrant/jenkins/certs/fullchain.pem,dst=/usr/share/nginx/certs/fullchain.pem,readonly \
--network cicd-network \
--restart always \
--name nginx-jenkins -p 80:80 -p 443:443 -d nginx:1.21.6-alpine

EOF

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/focal64"
  config.vm.provider "virtualbox" do |v|
    v.memory = 4096
    v.cpus = 1
  end
  config.vm.network "private_network", ip: "192.168.60.6"
  config.vm.network "forwarded_port", guest: 443, host: 36443 # remember to open host port on firewall
  config.vm.network "forwarded_port", guest: 80, host: 36080 # rememeber open host port on firewall
  config.vm.provision "file", source: ".", destination: "/home/vagrant/jenkins" # store docker file on vm
  config.vm.synced_folder "jenkins_home", "/home/vagrant/jenkins_home", create: true # persistant storage for jenkins container
  config.vm.provision "shell", inline: $docker_install
  config.vm.provision "shell", inline: $jenkins_nginx_install
end
