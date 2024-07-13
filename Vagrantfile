# NUM_OBSERVER_NODE = 1
NUM_ELASTIC_NODE = 3
IP_NW = "192.168.56."

ELASTIC_IP_START = 150

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/bionic64"
  config.vm.box_check_update = false

  config.vm.define "kibana" do |node|
      node.vm.provider "virtualbox" do |vb|
        vb.name = "kibana"
        vb.memory = 1024
        # vb.cpus = 0.5
      end
      node.vm.hostname = "kibana"
      node.vm.network :private_network, ip: "192.168.56.118"
      node.vm.network "forwarded_port", guest: 22, host: 12788
  end

  (1..NUM_ELASTIC_NODE).each do |i|
    config.vm.define "es0#{i}" do |node|
      node.vm.provider "virtualbox" do |vb|
        vb.name = "es0#{i}"
        vb.memory = 2048
        vb.cpus = 1
      end
      node.vm.hostname = "es0#{i}"
      node.vm.network :private_network, ip: IP_NW + "#{ELASTIC_IP_START + i}"
      node.vm.network "forwarded_port", guest: 22, host: "#{2288 + i}"
    end
  end

  config.vm.provision "setup-deployment-user", type: "shell" do |s|
    ssh_pub_key = File.readlines("./client.pem.pub").first.strip
    s.inline = <<-SHELL
        # create deploy user
        useradd -s /bin/bash -d /home/deploy/ -m -G sudo deploy
        echo 'deploy ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers
        mkdir -p /home/deploy/.ssh && chown -R deploy /home/deploy/.ssh
        echo #{ssh_pub_key} >> /home/deploy/.ssh/authorized_keys
        chown -R deploy /home/deploy/.ssh/authorized_keys
        # config timezone
        timedatectl set-timezone Asia/Ho_Chi_Minh
    SHELL
  end
end