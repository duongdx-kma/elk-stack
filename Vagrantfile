NUM_ELASTIC_NODE = 2
IP_NW = "192.168.61."

ELASTIC_IP_START = 150

Vagrant.configure("2") do |config|
  config.vm.box = "bento/ubuntu-22.04"
  config.vm.box_check_update = false

  # Kibana VM configuration
  config.vm.define "kibana" do |node|
      node.vm.provider "virtualbox" do |vb|
        vb.name = "kibana"
        vb.memory = 1024
      end
      node.vm.hostname = "kibana"
      node.vm.network :private_network, ip: "192.168.61.118"
      node.vm.network "forwarded_port", guest: 22, host: 12788
  end

  # Elasticsearch nodes configuration
  (1..NUM_ELASTIC_NODE).each do |i|
    config.vm.define "es0#{i}" do |node|
      node.vm.provider "virtualbox" do |vb|
        vb.name = "es0#{i}"
        vb.memory = 4096
        vb.cpus = 2
      end
      node.vm.hostname = "es0#{i}"
      node.vm.network :private_network, ip: IP_NW + "#{ELASTIC_IP_START + i}"
      node.vm.network "forwarded_port", guest: 22, host: "#{2288 + i}"
    end
  end

  # Provisioning setup for deploy user
  config.vm.provision "setup-deployment-user", type: "shell" do |s|
    ssh_pub_key = File.readlines("./client.pem.pub").first.strip
    s.inline = <<-SHELL
        # Create deploy user
        useradd -s /bin/bash -d /home/deploy/ -m -G sudo deploy
        echo 'deploy ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers
        mkdir -p /home/deploy/.ssh && chown -R deploy /home/deploy/.ssh
        echo #{ssh_pub_key} >> /home/deploy/.ssh/authorized_keys
        chown -R deploy /home/deploy/.ssh/authorized_keys
        # Configure timezone
        timedatectl set-timezone Asia/Ho_Chi_Minh
    SHELL
  end
end
